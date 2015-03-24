# Admin commands for the bot

module Cinch
  module Plugins
    class Admin
      include Cinch::Plugin

      timer 300, :method => :fix_name

      match /(?:exit|quit)/i,     :method => :command_exit

      def initialize(*args)
        super
        @admins = Array(config[:admins])
      end

      # Admin command that tells the bot to exit
      # !exit
      def command_exit(m)
        if !authed? m.user
          m.user.send "You are not authorized to exit #{shared[:Bot_Nick]}."
          return
        end

        m.user.send "#{shared[:Bot_Nick]} is shutting down. Good bye :("
        Process.exit
      end

      # Called every 5 minutes to attempt to fix the bots name.
      # This can happen if the bot gets disconnected and reconnects before
      # the last bot as been kicked from the IRC server.
      def fix_name
        if bot.nick != shared[:Bot_Nick]
          puts "Fixing nickname."
          bot.nick = shared[:Bot_Nick]
        end
      end

      private

      # Is a user an authorized user?
      # The user must be in the list of admins from the config file, and must
      # also be authenticated to NickServ.
      # param user: (Cinch::User) The user
      def authed?(user)
        @admins.include?(user.nick) && user.authed?
      end
    end
  end
end

