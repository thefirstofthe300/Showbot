require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'help_plugin' do
  it 'should respond to pleas for help' do
    expect(response_to '!help').to eq "PRIVMSG #{@ircd.tester_nick} :!help - Uh, this."
  end
end
