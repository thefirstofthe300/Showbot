require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'server plugin' do
  let(:irc_server) { "IRC info - Server: irc.geekshed.net, Channel: #jupiterbroadcasting" }
  let(:mumble_server) { "Mumble info - Server: mumble.jupitercolony.com, Port: 64734" }

  it 'should give us the help message for !server' do
    expect(response_to '!server', lines: 2).to match_array [
      "PRIVMSG #{@ircd.tester_nick} :Usage: !server <service>",
      "PRIVMSG #{@ircd.tester_nick} :where <service> is one of: irc, mumble"
    ]
  end

  it 'should give us the irc server info from !irc' do
    expect(response_to '!irc').to eq "PRIVMSG #{@ircd.tester_nick} :#{irc_server}"
  end

  it 'should give us the irc server info from !server irc' do
    expect(response_to '!server irc').to eq "PRIVMSG #{@ircd.tester_nick} :#{irc_server}"
  end

  it 'should give us the mumble info from !mumble' do
    expect(response_to '!mumble').to eq "PRIVMSG #{@ircd.tester_nick} :#{mumble_server}"
  end

  it 'should give us the mumble info from !server mumble' do
    expect(response_to '!server mumble').to eq "PRIVMSG #{@ircd.tester_nick} :#{mumble_server}"
  end
end
