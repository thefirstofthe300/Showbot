require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'bacon plugin' do
  it 'gives bacon' do
    expect(response_to '!bacon').to eq "PRIVMSG #{@ircd.channel} :\x01ACTION gives #{@ircd.tester_nick} a strip of delicious bacon.\x01"
  end

  it 'shares bacon' do
    target = @ircd.tester_nick
    expect(response_to "!bacon #{target}").to eq "PRIVMSG #{@ircd.channel} :\x01ACTION gives #{target} a strip of delicious bacon as a gift from #{@ircd.tester_nick}.\x01"
  end
end
