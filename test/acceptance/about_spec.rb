require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'about plugin' do
  it 'should tell us about itself' do
    # TODO: These should use the cinchbot's nick instead of "JBot"
    expect(response_to '!about', lines: 2).to match_array [
      "PRIVMSG #{@ircd.tester_nick} :JBot was created by Jeremy Mack (@mutewinter) and some awesome contributors on github.The project page is located at https://github.com/rikai/Showbot",
      "PRIVMSG #{@ircd.tester_nick} :Type !help for a list of JBot's commands"
    ]
  end
end
