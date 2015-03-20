module Cinch
  module Plugins
    class Bacon
      include Cinch::Plugin

      match /bacon$/i,        :method => :command_bacon       # !bacon
      match /bacon\s+(.+)/i,  :method => :command_bacon_gift  # !bacon <user>

      def help
        '!bacon - Delicious bacon.'
      end

      def help_bacon
        [
          help,
          'Usage: !bacon [user]'
        ].join "\n"
      end

      def command_bacon(m)
        return if !m.channel?

        m.action_reply "gives #{m.user} a strip of delicious bacon."
      end

      def command_bacon_gift(m, user)
        channel_user = find_channel_user(m, user)
        return if !channel_user

        m.safe_action_reply "gives #{channel_user} a strip of delicious bacon as a gift from #{m.user}."
      end

      private

      def find_channel_user(m, user)
        return nil if !m.channel?
        m.channel.users.keys.select do |channel_user|
          channel_user.to_s.casecmp(user).zero?
        end.first
      end
    end
  end
end
