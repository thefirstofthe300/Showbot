require 'cinch/cooldown'

module Cinch
  module Plugins
    class Quotes
      include Cinch::Plugin

      enforce_cooldown

      match /quote\s+(.+)/i,  :method => :command_quote
      match /([^\s]+)/i,      :method => :command_quote

      def initialize(*args)
        super
        if !config[:quotes_file].nil?
          quotes_path = File.join File.dirname(__FILE__), "../../../#{config[:quotes_file]}"
          quotes_yaml = YAML.load_file quotes_path
          @quote_list = QuoteList.new quotes_yaml
        else
          @quote_list = QuoteList.new(config)
        end
      end

      def command_quote(m, name)
        m.reply @quote_list.quote_for name
      end
    end
  end
end

