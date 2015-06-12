require './lib/models/shows'
require './lib/models/calendar'

module Cinch
  module Plugins
    class Schedule
      include Cinch::Plugin

      timer 600, :method => :refresh_calendar

      listen_to :connect, :method => :on_connect

      match /next\s*$/i,        :method => :command_next      # !next
      match /next\s+(.+)/i,     :method => :command_next_show # !next <show>
      match /schedule/i,        :method => :command_schedule  # !schedule

      def help
        [
          '!next - When\'s the next live show?',
          '!schedule - What shows are being recorded live in the next seven days?'
        ].join "\n"
      end

      def help_next
        [
          '!next - When\'s the next live show?',
          'Usage: !next [show]'
        ].join "\n"
      end

      def help_schedule
        [
          '!schedule - What shows are being recorded live in the next seven days?',
          'Usage: !schedule'
        ].join "\n"
      end

      def initialize(*args)
        super
        @calendar = Calendar.new(config)
        @events = []
      end

      # A method called on connection to an IRC server
      # Use to call any additional initialization
      def on_connect(m)
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
        response = ""

        event = live_event

        if event
          response << "#{event.summary} is live right now! "
        end

        event = next_event

        if event
          response << "Next show is #{event.summary}"
          response << " in #{in_how_long(event)}"
        else
          response << "No upcoming show found in the next week"
        end

        m.reply response
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
        response << " in #{in_how_long(event)}"

        m.reply response
      end

      # Replies with the schedule for the next 7 days of shows
      def command_schedule(m)
        if @events.empty?
          m.user.send "No shows in the next week"
          return
        end

        m.user.send "#{@events.length} upcoming show#{@events.length > 1 ? "s" : ""} in the next week"

        # Push only the next 10 shows to avoid flooding
        @events[0...10].each do |event|
          m.user.send "  #{event.summary} on #{event.start_date_to_local_string} at #{event.start_time_to_local_string}"
        end
      end

      protected

      def in_how_long(event)
        "#{event.fancy_time_until} (#{event.start_time_to_local_string} on #{event.start_date_to_local_string})"
      end

      # Get a live event if there is one, or nil
      def live_event
        @events.select do |event|
          event.covers? Time.now
        end.first
      end

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
          event.after? Time.now
        end.first
      end
    end
  end
end

