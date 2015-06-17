require 'twitter'
require 'htmlentities'
require 'chronic_duration'

module TwitterClient
  def self.new(config)
    users = convert_to_users_hash Array(config[:users])

    begin
      client = new_api_client(config)
      RealTwitterClient.new(client, users)
    rescue
      NilTwitterClient.new
    end
  end

  private

  def self.convert_to_users_hash(users_array)
    Hash[users_array.map { |user| [user, nil] }]
  end

  def self.new_api_client(config)
    ::Twitter::REST::Client.new do |client|
      client.consumer_key = config[:consumer_key]
      client.consumer_secret = config[:consumer_secret]
      client.access_token = config[:access_token]
      client.access_token_secret = config[:access_token_secret]
    end
  end

  class RealTwitterClient
    def initialize(client, users)
      @entities = HTMLEntities.new
      @statuses = users
      @client = client
    end

    def user_names
      @statuses.keys
    end

    def valid_twitter_user?(user)
      user = as_comparable_handle user
      user_names.any? do |canonical_name|
        canonical_name.downcase == user
      end
    end

    def last_status_for(user)
      return nil unless valid_twitter_user? user
      user = canonicalize_handle user
      @statuses[user]
    end

    def update_status_for(user)
      return false unless valid_twitter_user? user
      last_status = @statuses[user]

      new_status = @client.user_timeline(user, {
        :count => 1, # Get only the last tweet
        :exclude_replies => true, # Don't get replies
        :include_rts => false # Don't get retweets
      }).first
      new_status = TwitterStatus.new(user, new_status, @entities)

      return false if last_status == new_status

      @statuses[user] = new_status
      true
    end

    # TODO: I'm sure there's a more efficient way to do this
    def update_all_statuses
      updated_users = []

      @statuses.keys.each do |user|
        updated_users << user if update_status_for user
      end

      updated_users
    end

    private

    def strip_at_sign(handle)
      handle = handle[1..-1] if handle[0] == '@'
      handle
    end

    def as_comparable_handle(handle)
      strip_at_sign handle.downcase
    end

    def canonicalize_handle(handle)
      handle = as_comparable_handle handle
      user_names.select do |canonical_handle|
        canonical_handle.downcase == handle
      end.first
    end
  end

  class NilTwitterClient
    def user_names
      []
    end

    def valid_twitter_user?(user)
      false
    end

    def last_status_for(user)
      nil
    end

    def update_status_for(user)
      # no op
    end

    def update_all_statuses
      []
    end
  end

  class TwitterStatus
    attr_reader :handle
    alias_method :user, :handle

    def initialize(handle, api_status, htmlentities = HTMLEntities.new)
      @handle = handle
      @status = api_status
      @entities = htmlentities
    end

    def id
      return nil if @status.nil?
      @status.id
    end

    def posted_at
      return nil if @status.nil?
      @status.created_at.to_datetime
    end

    def text
      return '' if @status.nil?
      html_decode @status.text
    end

    def ==(other_status)
      return true if @status.nil? && other_status.nil?
      return false if @status.nil? || other_status.nil?

      @status.id == other_status.id
    end

    def to_s
      return '' if @status.nil?

      seconds_ago = (Time.now - posted_at.to_time).to_i
      posted_ago = ChronicDuration.output(seconds_ago, :format => :long)
      "@#{handle}: #{text} (#{posted_ago} ago)"
    end

    private

    def html_decode(text)
      text_decoded = nil

      until text == text_decoded do
        text_decoded = text
        text = @entities.decode text
      end

      text
    end
  end
end
