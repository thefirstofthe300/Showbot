require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Ltctick
      include Cinch::Plugin

      match /(litetick)/i,                    :method => :command_litetick

      def help
        '!litetick - Litecoin Ticker (BTC-E)'
      end

      def help_litetick
        "#{help}\nUsage: !litetick"
      end

      def command_litetick(m)
        json = open('https://btc-e.com/api/2/ltc_usd/ticker').read
        data = JSON::parse(json)["ticker"]

        last = "%0.2f" % data['last']
        high = "%0.2f" % data['high']
        low = "%0.2f" % data['low']
        vol = data['vol'].to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
        avg = "%0.2f" % data['avg']

# For 2.x
        m.reply "#{Format(:bold,'Average:')} #{Format(:orange,'$%<average>s')} #{Format(:bold,'Last:')} #{Format(:orange,'$%<last>s')} #{Format(:bold,'High:')} #{Format(:orange,'$%<high>s')} #{Format(:bold,'Low:')} #{Format(:orange,'$%<low>s')} #{Format(:bold,'Volume:')} #{Format(:orange,'%<vol>s LTC')}" % {
            average: avg,
            last: last,
            high: high,
            low: low,
            vol: vol
          }
      end
    end
  end
end

