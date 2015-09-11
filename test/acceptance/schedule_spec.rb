require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'schedule plugin' do
  # TODO: This test is flaky because the calendar data is not always loaded before we ask
  it 'tells us when the next show is' do
    expect(response_to '!next').to match /PRIVMSG #{@ircd.channel} :Next show is (.*) in (\d+ days? )?(\d+ hours? )?(\d+ minutes? )?(\d+ seconds?)? \(\d{1,2}:\d{2}[ap]m UTC on (Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day, \d{1,2}\/\d{1,2}\/\d{4}\)/
  end

  it 'tells us when the next Coder Radio is' do
    expect(response_to '!next cr').to match /PRIVMSG #{@ircd.channel} :The next Coder Radio is in (\d+ days? )?(\d+ hours? )?(\d+ minutes? )?(\d+ seconds?)? \(\d{1,2}:\d{2}[ap]m UTC on (Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day, \d{1,2}\/\d{1,2}\/\d{4}\)/
  end

  it 'does not find a next lol' do
    expect(response_to '!next lol').to eq "PRIVMSG #{@ircd.channel} :Cannot find a show for lol"
  end

  it 'tells us when the next show is, in our preferred timezone' do
    expect(response_to '!next --tz=US/Eastern').to match /PRIVMSG #{@ircd.channel} :Next show is (.*) in (\d+ days? )?(\d+ hours? )?(\d+ minutes? )?(\d+ seconds?)? \(\d{1,2}:\d{2}[ap]m E[DS]T on (Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day, \d{1,2}\/\d{1,2}\/\d{4}\)/
  end
end
