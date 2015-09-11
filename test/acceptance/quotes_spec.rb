require 'rspec'
require 'yaml'

require_relative '_helpers/spec_helper'

# TODO: This test specifically tests things that could change in the config file
# rather than testing the code. This needs to be changed to test the code
# by dynamically building tests from the config file.

# TODO: This pulls from the real config file, which is not in the repo (on
# purpose). Better instead would be to pull from a test-tailored quotes file.

describe_with_cinchbot 'quotes plugin' do
  def load_quotes(quotes_path = '/_config/quotes.yml')
    quotes_yml = File.join TEST_ROOT, quotes_path
    YAML.load_file quotes_yml
  end

  before(:context) do
    @quotes = load_quotes
  end

  def quotes_for person
    @quotes[person][:quotes].to_a.map do |quote|
      "PRIVMSG #{@ircd.channel} :#{quote}"
    end
  end

  it 'asks, shakes, and turns it over' do
    expect(response_to '!8ball will this test pass?').to be_in quotes_for '8ball'
  end

  it 'is negative in the freedom dimension' do
    expect(response_to '!rms').to be_in quotes_for 'RMS'
  end

  it 'patches its s***' do
    expect(response_to '!allan').to be_in quotes_for 'Allan'
  end

  it 'accidentally THE WHOLE THING!' do
    expect(response_to '!angela').to be_in quotes_for 'Angela'
  end

  it 'quoth the hair' do
    expect(response_to '!chris').to be_in quotes_for 'Chris'
  end
end
