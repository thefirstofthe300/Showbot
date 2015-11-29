require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'cinch bot' do
  it 'connects to the server' do
    expect(@ircd).to be_client_connected
  end
end
