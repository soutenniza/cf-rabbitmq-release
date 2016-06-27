require 'yaml'
require 'open3'
require 'ostruct'


RSpec.describe 'rabbitmq-server post-start template', template: true do
	let(:management_username) { "OperatorUser" }
	let(:management_password) { "OperatorPassword" }

	let(:post_start_env) { compiled_template('rabbitmq-server', 'post-start-env', {
			'rabbitmq-server'=>{
				'administrators' => {
					'management'=>{
						'username'=> management_username,
						'password'=> management_password
					}
				}
			}
		})
	}

	it "sets the right bash variables" do
		expect(post_start_env).to include("#!/usr/bin/env bash

MANAGEMENT_USERNAME=#{management_username}
MANAGEMENT_PASSWORD=#{management_password}")
	end
end
