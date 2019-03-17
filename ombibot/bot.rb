require "slack-ruby-bot"

module OmbiBot
  class Bot < SlackRubyBot::Bot
    help do
      title "H8NET Bot"
      desc "Ask me to download stuff for you."

      command 'request movie <movie name>' do
        desc 'Requests a movie on H8NET.'
      end

      command 'request tv <tv show name>' do
        desc 'Requests a show on H8NET.'
	long_desc 'This will download the full series of\n' \
		'an anime, cartoon, or other show.'
      end	
		
    end
  end
end
