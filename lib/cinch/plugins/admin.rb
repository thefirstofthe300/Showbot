# Admin commands for the bot

module Cinch
  module Plugins
    class Admin
      include JB::AdminPlugin

      DO_UNAUTHORIZED_MSG = 'You are not authorized for droplet access.'

      [{
        :pattern => /(?:exit|quit)/i,
        :method => :command_exit,
        :unauthorized_msg => 'You are not authorized to command the bot to exit.'
      }, {
        :pattern => /start_show$/i,
        :method => :command_show_list,
        :unauthorized_msg => 'You are not authorized to start a show.'
      }, {
        :pattern => /start_show\s+(.+)/i,
        :method => :command_start_show,
        :unauthorized_msg => 'You are not authorized to start a show.'
      }, {
        :pattern => /end_show/i,
        :method => :command_end_show,
        :unauthorized_msg => 'You are not authorized to end a show.'
      }, {
        :pattern => /join\s(.+)/i,
        :method => :command_join,
        :unauthorized_msg => 'You are not authorized to invite the bot.'
      }, {
        :pattern => /leave\s(.+)/i,
        :method => :command_leave,
        :unauthorized_msg => 'You are not authorized to make the bot leave.'
      }].each do |m|
        admin_match m[:pattern], {
          :method => m[:method],
          :unauthorized_msg => m[:unauthorized_msg]
        }
      end

      [{
        :pattern => /droplet\slist$/i,
        :method => :command_droplet_list,
      }, {
        :pattern => /droplet\sstart\s(.+)/i,
        :method => :command_droplet_start,
      }, {
        :pattern => /droplet\sstop\s(.+)/i,
        :method => :command_droplet_stop,
      }, {
        :pattern => /droplet\sshutdown\s(.+)/i,
        :method => :command_droplet_shutdown,
      }].each do |m|
        admin_match m[:pattern], {
          :method => m[:method],
          :unauthorized_msg => Admin::DO_UNAUTHORIZED_MSG
        }
      end

      def initialize(*args)
        super
        @data_json = DataJSON.new config[:data_json]
        @do_client = DropletKit::Client.new(access_token: ENV['DO_API_KEY']) if ENV['DO_API_KEY']
      end

      def command_join(m, channel)
        Channel(channel).join
      end

      def command_leave(m, channel)
        Channel(channel).part
      end

      def command_show_list(m)
        shows = Shows.shows
        shows.each do |show|
          m.user.send "#{show.title}: !start_show #{show.url}"
        end
      end

      def command_start_show(m, show_slug)
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

      def command_exit(m)
        bot.channels.each do |channel|
          channel.send "#{shared[:Bot_Nick]} is shutting down. Good bye :("
        end
        Process.exit
      end

      ############################################################
      # Digital Ocean Hooks
      # TODO: Deserves its own module
      # TODO: Error hardening
      # TODO: Force stop?
      ############################################################
      def find_droplet_by_name(name)
        @do_client.droplets.all.find { |droplet| droplet.name == name }
      end

      def command_droplet_list(m)
        m.user.send '=============================='
        m.user.send 'Listing known droplets...'
        m.user.send '=============================='

        @do_client.droplets.all.each do |droplet|
          m.user.send "[#{droplet[:name]}]"
#          m.user.send "  id: #{droplet[:id]}"
          m.user.send "  status: #{droplet[:status]}"
        end

        m.user.send '=============================='
        m.user.send 'Droplet list complete.'
        m.user.send '=============================='
      end

      def command_droplet_start(m, name)
        begin
          @do_client.droplet_actions.power_on(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to start droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to start. Is your ID correct?'
        end
      end

      def command_droplet_stop(m, name)
        begin
          @do_client.droplet_actions.power_off(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to stop droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to stop. Is your ID correct?'
        end
      end

      def command_droplet_shutdown(m, name)
        begin
          @do_client.droplet_actions.shutdown(droplet_id: find_droplet_by_name(name).id)
          m.user.send "Request to stop droplet #{name} succeeded!"
        rescue
          m.user.send 'An error occurred requesting the droplet to stop. Is your ID correct?'
        end
      end
    end
  end
end

