require 'chronic_duration'
require './lib/models/shows'
require './lib/models/calendar'

module Cinch
  module Plugins
    class Schedule
      include Cinch::Plugin

      timer 600, :method => :refresh_calendar

      match /next\s*$/i,        :method => :command_next      # !next
      match /next\s+(.*)/i,     :method => :command_next_show # !next <show>
      match /schedule\s?(.*)/i, :method => :command_schedule  # !schedule

      def initialize(*args)
        super
        @calendar = Calendar.new(config)
        @events = []
        refresh_calendar
      end

      # Pulls in the latest calendar events and stores them in @events
      # Called by a timer to keep up to date with the calendar
      def refresh_calendar
        @events = @calendar.events
      end

      # Replies to the user with information about the next show
      # !next -> Next show is Linux Action Show in 3 hours 30 minutes (6/2/2011)
      def command_next(m)
        event = next_event

        if event
          response = ""

          response << "Next show is #{event.summary}"

          date_string, time_string = to_local_date_and_time_strings(event.start_time)
          response << " in #{ChronicDuration.output(seconds_until(event.start_time), :format => :long)} (#{time_string} on #{date_string})"

          m.reply response
        else
          m.reply "No upcoming show found in the next week"
        end
      end

      # Replies to the user with information about the next specified show
      # !next cr -> The next Coder Radio is in 3 hours 30 minutes (6/2/2011)
      def command_next_show(m, show_keyword)
        if show_keyword.strip.empty?
          command_next(m)
          return
        end

        show = Shows.find_show(show_keyword)

        if !show
          if show_keyword.strip == "Robert'); DROP TABLE students;--"
            m.reply "Oh, yes. Little Bobby Tables, we call him."
          else
            m.reply "Cannot find a show for #{show_keyword}"
          end

          return
        end

        event = next_event(show)

        if !event
          m.reply "No upcoming show found for #{show.title} in the next week"
          return
        end

        response = ""

        response << "The next #{event.summary} is"

        date_string, time_string = to_local_date_and_time_strings(event.start_time)
        response << " in #{ChronicDuration.output(seconds_until(event.start_time), :format => :long)} (#{time_string} on #{date_string})"

        m.reply response
      end

      # Replies with the schedule for the next 7 days of shows
      def command_schedule(m, command)
        if @events.empty?
          m.user.send "No shows in the next week"
          return
        end

        m.user.send "#{@events.length} upcoming show#{@events.length > 1 ? "s" : ""} in the next week"

        # Push only the next 10 shows to avoid flooding
        @events[0...10].each do |event|
          date_string, time_string = to_local_date_and_time_strings(event.start_time)
          m.user.send "  #{event.summary} on #{date_string} at #{time_string}"
        end
      end

      protected

      # Gets the next event from the list of events
      # If a show is provided, search the events for a summary that starts with
      # show.title, and return the next event of that show
      def next_event(show = nil)
        if show.nil?
          @events
        else
          @events.select do |event|
            event.summary.start_with? show.title
          end
        end.select do |event|
          event.start_time > Time.now
        end.first
      end

      # Convert a DateTime to local date and time strings
      # Returns [datestring, timestring]
      def to_local_date_and_time_strings(time)
        [
          time.strftime("%A, %-m/%-d/%Y"),
          time.strftime("%-I:%M%P EST")
        ]
      end

      # Get the number of seconds until event_time
      def seconds_until(event_time)
        (event_time - Time.now).to_i
      end
    end
  end
end

