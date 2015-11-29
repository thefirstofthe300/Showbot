require 'rspec'

require_relative '_helpers/spec_helper'

describe_with_cinchbot 'ticker plugins' do
  # TODO: The messages here vary in a few ways. Is it possible to make them more consistent?

  describe 'bittick plugin' do
    it 'replies with the Bitcoin averages' do
      expect(response_to '!bitavg').to match_all [
        /^PRIVMSG #{@ircd.channel} :/,
        /\x0302BitcoinAverage:\x0F/,
        /\x0224h Average:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Last:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Ask:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Bid:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Volume:\x0F \x0307(?:\d{1,3},)*\d{1,3}(\.\d+)? BTC\x0F$/
      ]
    end

    it 'replies with the BTC-E numbers' do
      expect(response_to '!btcetick').to match_all [
        /^PRIVMSG #{@ircd.channel} :/,
        /\x0302BTC-E:\x0F/,
        /\x02Average:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Last:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02High:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Low:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Volume:\x0F \x0307\$(?:\d{1,3},)*\d{1,3}(\.\d+)?\x0F$/
      ]
    end

    it 'replies with the Dogecoin numbers' do
      expect(response_to '!dogetick').to match_all [
        /^PRIVMSG #{@ircd.channel} :/,
        /\x0302BTer:\x0F/,
        /\x0224h Average:\x0F \x0307\d+(\.\d+)? BTC\x0F/,
        /\x02Last:\x0F \x0307\d+(\.\d+)? BTC\x0F/,
        /\x02Ask:\x0F \x0307\d+(\.\d+)? BTC\x0F/,
        /\x02Bid:\x0F \x0307\d+(\.\d+)? BTC\x0F/,
        /\x02Volume:\x0F \x0307(?:\d{1,3},)*\d{1,3}(\.\d+)? DOGE\x0F$/
      ]
    end
  end

  describe 'ltctick plugin' do
    it 'replies with the Litecoin numbers' do
      expect(response_to '!litetick').to match_all [
        /^PRIVMSG #{@ircd.channel} :/,
        /\x02Average:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Last:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02High:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Low:\x0F \x0307\$\d+(\.\d+)?\x0F/,
        /\x02Volume:\x0F \x0307(?:\d{1,3},)*\d{1,3}(\.\d+)? LTC\x0F$/
      ]
    end
  end
end
