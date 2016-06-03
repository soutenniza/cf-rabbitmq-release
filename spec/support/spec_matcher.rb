require 'rspec/expectations'
require 'yaml'

module Matchers
  class Firehose
    attr_reader :log_lines

    def initialize(doppler_address:, access_token:)
      @doppler_address = doppler_address
      @access_token = access_token
    end

    def read_logs_for(time: 300)
      puts "Firehose is reading logs..."

      file = Tempfile.new('smetrics')
      pid = spawn(
        {
          'DOPPLER_ADDR' => @doppler_address,
          'CF_ACCESS_TOKEN' => @access_token,
        },
        'firehose',
        [:out, :err] => [file.path, 'w']
      )
      sleep time
      @log_lines = file.readlines
    ensure
      Process.kill("INT", pid)
      file.close
      file.unlink
    end
  end

  RSpec::Matchers.define :have_metric do |job_name, job_index, metric_regex_pattern|
    match do |firehose|
      @actual = firehose.log_lines

      metric_exist = firehose.log_lines.grep(metric_regex_pattern).any? do |metric|
        matched = metric.include? 'origin:"p-rabbitmq"'
        matched &= metric.include? "deployment:\"#{deployment_name}\""
        matched &= metric.include? 'eventType:ValueMetric'
        matched &= metric =~ /job:\".*#{job_name}.*\"/
          matched &= metric.include? "index:\"#{job_index}\""

        matched &= metric =~ /timestamp:\d/
        matched &= metric =~ /ip:"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"/
      end

      metric_exist
    end

    failure_message do |actual|
      tmp_dir = Dir.mktmpdir("metrics")
      log_file_path = File.join(tmp_dir, "test_output_#{Time.now.to_i}.log")

      FileUtils.touch(log_file_path)

      file = File.open(log_file_path, 'w')
      file.write(@actual.join)
      file.close

      "expected file #{file.path} to contains metric '#{metric_regex_pattern}' for job '#{job_name}' with index '#{job_index}'"
    end
  end


  def deployment_name
    manifest_path = ENV.fetch('BOSH_MANIFEST') { File.expand_path('../../manifests/cf-rabbitmq-lite.yml', __FILE__) }
    manifest = YAML.load(File.open(manifest_path).read)
    if manifest["name"].nil? or manifest["name"].empty?
      "cf-rabbitmq"
    else
      manifest['name']
    end
  end
end
