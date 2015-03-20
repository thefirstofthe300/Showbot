require 'open-uri'
require 'json'
#dirty hack because mtgox sucks and has an invalid cert - comment this when they fix their cert
require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module Cinch
  module Plugins
    class Bittick
      include Cinch::Plugin

#      listen_to :message
      match /(goxtick)/i,                    :method => :command_goxtick
      match /(btcetick)/i,                    :method => :command_btcetick
      match /(bittick)/i,                    :method => :command_bittick
      match /(bitavg)/i,                    :method => :command_bitavg
      match /(dogetick)/i,                    :method => :command_dogetick

      def help
        [
          '!goxtick - Bitcoin Ticker (MtGox)',
          '!bitavg - Bitcoin averages from bitcoinaveages.com',
          '!btcetick - Bitcoin Ticker (BTC-E)',
          '!dogetick - Dogecoin Ticker (BTer)'
        ].join "\n"
      end

      def help_goxtick
        [
          '!goxtick - Bitcoin Ticker (MtGox)',
          'Usage: !goxtick'
        ].join "\n"
      end

      def help_btcetick
        [
          '!btcetick - Bitcoin Ticker (BTC-E)',
          'Usage: !btcetick'
        ].join "\n"
      end

      def help_bittick
        '!bittick is deprecated, please use !bitavg for the average across all exchanges, !goxtick for MtGox and !btcetick for BTC-E, thanks!'
      end

      def help_bitavg
        [
          '!bitavg - Bitcoin averages from bitcoinaveages.com',
          'Usage: !bitavg'
        ].join "\n"
      end

      def help_dogetick
        [
          '!dogetick - Dogecoin Ticker (BTer)',
          'Usage: !dogetick'
        ].join "\n"
      end

      def command_bittick(m)
        m.user.send help_bittick
      end

      def command_goxtick(m)
        goxjson = open('https://data.mtgox.com/api/2/BTCUSD/money/ticker').read
        goxdata = JSON::parse(goxjson)["data"]
        goxlast = goxdata["last"]
        goxhigh = goxdata["high"]
        goxlow = goxdata["low"]
        goxvol = goxdata["vol"]
        goxavg = goxdata["avg"]
        goxsell = goxdata["sell"]

# For 2.x
        m.reply "#{Format(:blue,'MtGox:')} #{Format(:bold,'Average:')} #{Format(:orange,'%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'%<last>s')} #{Format(:bold,'High:')} #{Format(:orange,'%<high>s')} #{Format(:bold,'Low:')} #{Format(:orange,'%<low>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s')}" % {
            average: goxavg['display'],
            last: goxlast['display'],
            high: goxhigh['display'],
            low: goxlow['display'],
            vol: goxvol['display']
          }
      end

      def command_btcetick(m)
        btcejson = open('https://btc-e.com/api/2/btc_usd/ticker').read
        btcedata = JSON::parse(btcejson)["ticker"]
        btcedata["avg"] = "%.2f" % btcedata["avg"]
        btcedata["high"] = "%.2f" % btcedata["high"]
        btcedata["low"] =  "%.2f" % btcedata["low"]
        btcedata['vol'] = "%.2f" % btcedata['vol']

# For 2.x
        m.reply "#{Format(:blue,'BTC-E:')} #{Format(:bold,'Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'High:')} #{Format(:orange,'$%<high>s')} #{Format(:bold,'Low:')} #{Format(:orange,'$%<low>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'$%<vol>s')}" % {
            average: btcedata['avg'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            last: btcedata['last'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            high: btcedata['high'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            low: btcedata['low'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2'),
            vol: btcedata['vol'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end

      def command_bitavg(m)
        bitavgjson = open('https://api.bitcoinaverage.com/ticker/global/USD/').read
        bitavgdata = JSON::parse(bitavgjson)

# For 2.x
        m.reply "#{Format(:blue,'BitcoinAverage:')} #{Format(:bold,'24h Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'Ask:')} #{Format(:orange,'$%<ask>s')} #{Format(:bold,'Bid:')} #{Format(:orange,'$%<bid>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s BTC')}" % {
            average: bitavgdata['24h_avg'],
            last: bitavgdata['last'],
            ask: bitavgdata['ask'],
            bid: bitavgdata['bid'],
            vol: bitavgdata['volume_btc'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end

      def command_dogetick(m)
        dogejson = open('https://data.bter.com/api/1/ticker/doge_btc').read
        dogedata = JSON::parse(dogejson)

        m.reply "#{Format(:blue,'BTer:')} #{Format(:bold,'24h Average:')} #{Format(:orange,'%<average>s BTC')} #{Format(:bold,'Last:')} #{Format(:orange,'%<last>s BTC')} #{Format(:bold,'Ask:')} #{Format(:orange,'%<ask>s BTC')} #{Format(:bold,'Bid:')} #{Format(:orange,'%<bid>s BTC')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s DOGE')}" % {
            average: dogedata['avg'],
            last: dogedata['last'],
            ask: dogedata['sell'],
            bid: dogedata['buy'],
            vol: dogedata['vol_doge'].to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
          }
      end
    end
  end
end

