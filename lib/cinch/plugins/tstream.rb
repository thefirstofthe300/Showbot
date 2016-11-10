# A Cinch plugin for streaming Twitter updates to an IRC channel
require 'tweetstream'

module Cinch
  module Plugins
    class TStream
      include Cinch::Plugin

      listen_to :connect,   :method => :on_connect

#      match /last_status$/i,        :method => :command_last_status_list
#      match /last_status\s+(.*)/i,  :method => :command_last_status

#      def help
#        "!last_status - The last tweet by @#{@client.user_names.join(", @")} delievered to you in IRC. Sweet."
#      end

#      def help_last_status
#        "#{help}\nUsage: !last_status <username>"
#      end

      def initialize(*args)
        super

        @channel = config[:channel]
        @channel_test = config[:channel_test]

      end

      def init_rest_twitter
        ::Twitter::REST::Client.new do |rest|
          rest.consumer_key        = config[:consumer_key]
          rest.consumer_secret     = config[:consumer_secret]
          rest.access_token        = config[:oauth_token]
          rest.access_token_secret = config[:oauth_token_secret]
        end
      end


    def on_connect(m)
        TweetStream.configure do |client|
          client.consumer_key = config[:consumer_key]
          client.consumer_secret = config[:consumer_secret]
          client.oauth_token = config[:oauth_token]
          client.oauth_token_secret = config[:oauth_token_secret]
          client.auth_method        = :oauth
        end

        @users = Array(config[:users])
        @rest_twitter = init_rest_twitter
        ids = []
        @users.each do |z|
          ids.push(@rest_twitter.user(z).id)
        end
        ids = ids.join(',')

        client = ::TweetStream::Client.new
        Thread.new do
          client.follow(ids) do |status|
            if ids.include?(status.user.id.to_s) && status.in_reply_to_status_id.nil? && status.in_reply_to_screen_name.nil?
              Channel(@channel).send "[Twitter] @#{status.user.screen_name}: #{status.text}"
            end
          end
          client.on_error do |message|
            puts "Error: #{message}"
          end
        end
#        bot.loggers.debug "boop"
      end
    end
  end
end