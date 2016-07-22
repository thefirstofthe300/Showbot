module Cinch
  module Plugins
    class Quotes
      include Cinch::Plugin

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
        @owner_nick = shared[:owner]
        @has_ns = shared[:server_has_nickserv]
        @allow_op_msgs = shared[:allow_op_msgs]
      end

      def command_quote(m, name)
        m.reply @quote_list.quote_for name
      end

      def authed?(user)
        if @allow_op_msgs
          (user.nick == @owner_nick || user.oper?) && (user.authed? || !@has_ns)
        else
          user.nick == @owner_nick && (user.authed? || !@has_ns)
        end
      end
    end
  end
end

