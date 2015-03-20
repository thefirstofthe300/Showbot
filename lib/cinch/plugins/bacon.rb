module Cinch
  module Plugins
    class Bacon
      include Cinch::Plugin

      match /bacon$/i,        :method => :command_bacon       # !bacon

      def help
        '!bacon - Delicious bacon.'
      end

      def help_bacon
        [
          help,
          'Usage: !bacon'
        ].join "\n"
      end

      def command_bacon(m)
#        if ["bunny", "madjo", "nogal", "nogal|work"].include?(m.user.nick) # In case i ever want to go back to 'restricting' the command
          m.channel.action "gives #{m.user.nick} a strip of delicious bacon."
#        else
#          m.reply "This bacon is reserved for true bacon connoisseurs, #{m.user.nick}!" # This stuff too.
#        end
      end
    end
  end
end
