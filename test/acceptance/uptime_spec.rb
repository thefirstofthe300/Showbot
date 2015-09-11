require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'uptime plugin' do
  it 'should tell us its uptime' do
    # TODO: Bug where, when running for zero seconds, no relative time is given
    expect(response_to '!uptime').to match /PRIVMSG #{@ircd.tester_nick} :#{@ircd.cinch_nick} has been running for (\d{1,2} days? )?(\d{1,2} hours? )?(\d{1,2} minutes )?(\d{1,2} seconds?)?, since \d{1,2}\/\d{1,2}\/\d{4} at \d{1,2}:\d{2}[ap]m/
  end
end
