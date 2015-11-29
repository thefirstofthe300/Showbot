require 'rspec'
require 'yaml'

require_relative 'globals_helper'
require_relative 'cinchbot_helper'
require_relative '../_fakes/ircd'

#Custom contexts

# This contexts provides all of the base hooks for testing against a cinchbot.
# It reduces the boilerplate code needed to run each test. It should only be
# used in the outermost context, as it creates and runs fake IRCd and cinchbot
# instances.
def describe_with_cinchbot(comment, &block)
  context_class = context comment.to_s do
    before(:context) do
      @config = YAML.load_file File.join(TEST_ROOT, '/_config/cinchize.yml')
      @ircd = Ircd.new @config['servers']['network_test']['nick'], @config['servers']['network_test']['channels'].first
      @cinchbot = start_cinchbot
      @ircd.accept_client
    end

    after(:example) do
      @ircd.flush_read
    end

    after(:context) do
      kill_cinchbot @cinchbot
      @ircd.close
    end
  end

  def response_to(message, lines: 1)
    responses = []

    @ircd.tester_send_channel message

    lines.times do
      responses << @ircd.gets
    end

    return responses.first if lines == 1
    responses
  end

  def response_to_private_message(message, lines: 1)
    responses = []

    @ircd.tester_send_bot message

    lines.times do
      responses << @ircd.gets
    end

    return responses.first if lines == 1
    responses
  end

  context_class.class_eval &block
end

# Custom matchers

# Test that an actual result is in a collection.
# This is good for checking random pulls from a collection.
RSpec::Matchers.define :be_in do |expected|
  match do |actual|
    expected.include? actual
  end
end

# Test that an actual result matches all of the regex patterns in a collection
RSpec::Matchers.define :match_all do |expected|
  match do |actual|
    expected.all? do |pattern|
      actual =~ pattern
    end
  end
end
