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
        if name.start_with?("add ","del ", "alias ") || name == "dump"
          m.user.send("You have to be an admin to use that command.") and return unless authed? m.user

          command = name.split(" ")
          case command.first
          when "add"
            add_quote(m, command)
          when "del"
            del_quote(m, command)
          when "dump"
            debug @quote_list.quotes.to_s
          when "alias"
            m.user.send("Alias commands require four arguments.") and return if command.length != 4
            case command[1]
            when "add"
              add_alias(m, command)
            when "del"
              del_alias(m, command)
            end
          end
        else
          m.reply @quote_list.quote_for name
        end
      end

      private

      def add_quote(m, command)
        m.user.send("I need more arguments for that command.") and return if command.length < 3
        @quote_list.add(command[1], command[2..-1].join(" "))
        save_to_disk
        m.reply("Quote added!")
      end

      def del_quote(m, command)
        m.user.send("I need more arguments for that command.") and return if command.length < 3
        @quote_list.del(command[1], command[2..-1].join(" "))
        save_to_disk
        m.reply("Quote removed!")
      end

      def add_alias(m, command)
        @quote_list.add_alias(command[2], command[3])
        save_to_disk
        m.reply("Alias added!")
      end

      def del_alias(m, command)
        @quote_list.del_alias(command[2], command[3])
        save_to_disk
        m.reply("Alias removed!")
      end

      def save_to_disk
        if !config[:quotes_file].nil?
          quotes_path = File.join File.dirname(__FILE__), "../../../#{config[:quotes_file]}"
          File.open(quotes_path, "w") {|file| file.write(@quote_list.quotes.to_yaml)}
        else
          User(shared[:owner]).send("Couldn't save quotes file; no location specified in config.")
        end
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

