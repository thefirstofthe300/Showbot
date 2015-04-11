# A Cinch plugin for broadcasting Twitter updates to an IRC channel
module Cinch
  module Plugins
    class Twitter
      include Cinch::Plugin

      listen_to :connect,   :method => :on_connect

      timer 60, :method =>  :poll_for_statuses

      match /last_status$/i,        :method => :command_last_status_list
      match /last_status\s+(.*)/i,  :method => :command_last_status

      def help
        "!last_status - The last tweet by @#{@client.user_names.join(", @")} delievered to you in IRC. Sweet."
      end

      def help_last_status
        "#{help}\nUsage: !last_status <username>"
      end

      def initialize(*args)
        super
        @client = TwitterClient.new config
      end

      def on_connect(m)
        @client.update_all_statuses
      end

      def poll_for_statuses
        updated_users = @client.update_all_statuses

        updated_users.each do |user|
          status = @client.last_status_for user
          bot.channels.each_with_object(status.to_s, &:send)
        end
      end

      def command_last_status_list(m)
        m.user.send "Here are the Twitter users I know: @#{@client.user_names.join(", @")}"
      end

      def command_last_status(m, user)
        user = trim_at_sign user
        last_status = @client.last_status_for user
        if last_status.nil?
          m.user.send "Sorry, #{user} is not a user I know."
        else
          m.user.send last_status
        end
      end

      private

      def trim_at_sign(user)
        user = user[1..-1] if user[0] == '@'
        user
      end
    end
  end
end
