require 'yaml'
require 'open3'
require 'ostruct'


RSpec.describe 'rabbitmq-server post-start template', template: true do
	let(:operator_username) { "OperatorUser" }
	let(:operator_password) { "OperatorPassword" }
	let(:rmq_ctl) { "CTLBIN" }

	let(:post_start) do
		template = compiled_template('rabbitmq-server', 'post-start', {
			'rabbitmq-server'=>{
				'administrators' => {
					'management'=>{
						'username'=> operator_username,
						'password'=> operator_password
					}
				}
			}
		})

		template_file = Tempfile.new("post_start")
		begin
			template_file.write(template)
			FileUtils.chmod("+x", template_file.path)
		ensure
			template_file.close
		end
		template_file.path
	end

	def run_post_start(&block)
		startup_log = Tempfile.new("startup_log")
		startup_log.close
		operator_username_file = Tempfile.new("operator_username_file")
		operator_username_file.close

		outputs = OpenStruct.new
		outputs.startup_log = startup_log.path
		outputs.operator_username_file = operator_username_file.path

		outputs.stdout, outputs.stderr, status = Open3.capture3(
			{
				"RABBIT_CTL"=>"echo #{rmq_ctl}",
				"STARTUP_LOG"=>outputs.startup_log,
				"OPERATOR_USERNAME_FILE"=>outputs.operator_username_file
			},
			post_start)


		block.call(outputs, status.exitstatus)
	ensure
		FileUtils.rm(post_start)
		FileUtils.rm(outputs.startup_log)
		FileUtils.rm(outputs.operator_username_file)
	end

	it 'exits with status 0' do
		run_post_start do |outputs, status|
			expect(status).to eq(0)
		end
	end

	describe 'management user' do
		it 'creates an operator admin user' do
			run_post_start do |outputs, status|
				expect(File.read(outputs.startup_log)).to include("#{rmq_ctl} add_user #{operator_username} #{operator_password}")
			end
		end

		it 'adds an operator username in $OPERATOR_USERNAME_FILE' do
			run_post_start do |outputs, status|
				expect(File.read(outputs.operator_username_file)).to include(operator_username)
			end
		end

		# context 'when the operator password is not set' do
		# 	let(:operator_username) { "" }

		# 	it 'does not create the user' do
		# 		run_post_start do |outputs, status|
		# 			expect(File.read(outputs.operator_username_file)).not_to include(operator_username)
		# 		end
		# 	end
		# end

		# context 'when the operator username is not set' do
		# 	it 'does not write the username to the file' do

		# 	end
		# 	it 'does not create the user' do
		# 	end
		# end

	end

end


