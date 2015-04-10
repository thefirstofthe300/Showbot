# Admin commands for the bot

module Cinch
  module Plugins
    class Admin
      include Cinch::Plugin

      match /(?:exit|quit)/i,     :method => :command_exit
      match /start_show\s+(.+)/i, :method => :command_start_show
      match /end_show/i,          :method => :command_end_show
      match /join\s(.+)/i,        :method => :command_join
      match /leave\s(.+)/i,       :method => :command_leave

      def initialize(*args)
        super
        @admins = Array(config[:admins])
        @data_json = DataJSON.new config[:data_json]
      end

      def command_join(m, channel)
        if !authed? m.user
          m.user.send 'You are not authorized to invite the bot.'
          return
        end

        Channel(channel).join
      end

      def command_leave(m, channel)
        if !authed? m.user
          m.user.send 'You are not authorized to make the bot leave.'
          return
        end

        Channel(channel).part
      end


      def command_start_show(m, show_slug)
        if !authed? m.user
          m.user.send 'You are not authorized to start a show.'
          return
        end

        show = Shows.find_show show_slug
        if show.nil?
          m.user.send 'Sorry, but I couldn\'t find that particular show.'
          return
        end

        begin
          @data_json.start_show show

          bot.channels.each do |channel|
            channel.send "#{show.title} starts now!"
          end
        rescue IOError => err
          exception err
          m.user.send 'IO Error: Cannot persist data!'
        end
      end

      def command_end_show(m)
        if !authed? m.user
          m.user.send 'You are not authorized to end a show.'
          return
        end

        if !@data_json.live?
          m.user.send 'No live show, but thanks for playing!'
          return
        end

        title = @data_json.title

        begin
          @data_json.end_show

          bot.channels.each do |channel|
            channel.send "Show's over, folks. Thanks for coming to #{title}!"
          end
        rescue IOError => err
          exception err
          m.user.send 'IO Error: Cannot persist data!'
        end
      end

      # Admin command that tells the bot to exit
      # !exit
      def command_exit(m)
        if !authed? m.user
          m.user.send "You are not authorized to exit #{shared[:Bot_Nick]}."
          return
        end

        bot.channels.each do |channel|
          channel.send "#{shared[:Bot_Nick]} is shutting down. Good bye :("
        end
        Process.exit
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

