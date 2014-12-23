require 'google/api_client'

module Calendar
  # Create a new Calendar object, here a GoogleCalendar object
  def self.new(config = {})
    google_config = {
      :app_name => config[:app_name],
      :app_version => config[:app_version],
      :calendar_id => config[:calendar_id],
      :api_key => config[:api_key]
    }

    google_client = Google::APIClient.new(
      :application_name => google_config[:app_name],
      :application_version => google_config[:app_version],
      :key => google_config[:api_key],
      :authorization => nil
    )

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
        :authenticated => false,
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
