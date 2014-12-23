require 'google/api_client'

module Calendar
  CWD = Dir.pwd # This needs to be here, or else it doesn't correctly get the cwd

  # Create a new Calendar object, here a GoogleCalendar object
  def self.new(config = {})
    google_config = {
      :app_name => config[:app_name],
      :app_version => config[:app_version],
      :calendar_id => config[:calendar_id],
      :service_email => config[:service_email],
      :key_file => "#{CWD}/#{config[:key_file]}" # Get key file relative to app root
    }

    google_client = Google::APIClient.new(
      :application_name => google_config[:app_name],
      :application_version => google_config[:app_version]
    )

    key = Google::APIClient::PKCS12.load_key(google_config[:key_file], 'notasecret')
    asserter = Google::APIClient::JWTAsserter.new(google_config[:service_email], [
      'https://www.googleapis.com/auth/calendar.readonly'
    ], key)
    google_client.authorization = asserter.authorize()

    google_api = google_client.discovered_api('calendar', 'v3')

    GoogleCalendar.new(google_config, google_client, google_api)
  end

  class GoogleCalendar
    def initialize(config, client, api)
      @config = config
      @client = client
      @calendar = api
    end

    # Get live events for the next 7 days
    # Live events start with "LIVE: "
    # Returns an array of CalendarEvent objects
    # Events are ordered by start time, ascending
    # The "LIVE: " prefix is stripped from the event summary
    def events
      results = @client.execute(
        :api_method => @calendar.events.list,
        :parameters => {
          'calendarId' => @config[:calendar_id],
          'fields' => 'items(start,summary)',
          'singleEvents' => true,
          'orderBy' => 'startTime',
          'timeMin' => DateTime.now.to_s,
          'timeMax' => (DateTime.now + 7).to_s,
          'q' => 'LIVE'
        }
      )

      results.data.items.map do |event|
        summary = event.summary.gsub(/^LIVE:\s+/, '')
        CalendarEvent.new(summary, event.start.date_time)
      end
    end
  end

  class CalendarEvent
    attr_reader :summary
    attr_reader :start_time

    def initialize(summary, start_time)
      @summary = summary
      @start_time = start_time
    end
  end
end
