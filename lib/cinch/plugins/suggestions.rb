# All suggestions welcome.

module Cinch
  module Plugins
    class Suggestions
      include Cinch::Plugin

      match /suggest\s+(.*)/i,  :method => :command_suggest       # !suggest Great Title Here

      # Show help for the suggestions module
      def help
        '!suggest - Be heard. Suggest a title for the live show.'
      end

      def help_suggest
        [
          help,
          'Usage: !suggest Sweet Show Title'
        ].join "\n"
      end

      # Add the user's suggestion to the database
      def command_suggest(m, title)
        if title.empty?
          m.user.send help_suggest
        else
          new_suggestion = Suggestion.create(
            :title      => title,
            :user       => m.user.nick
          )

          if new_suggestion.saved?
            m.user.notice "Added title suggestion \"#{new_suggestion.title}\""
          else
            new_suggestion.errors.each do |e|
              m.user.notice e.first
            end
          end
        end
      end
    end
  end
end

