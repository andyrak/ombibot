require "httparty"
require "uri"
HTTParty::Basement.default_options.update(verify: false)

OMBI_API_KEY = ENV["OMBI_API_KEY"]
OMBI_URL = ENV["OMBI_URL"]

MAX_RESULTS = 3

module OmbiBot
  module Commands
    class Request < SlackRubyBot::Commands::Base
      command "movie" do |client, data, match|
        query = URI.escape(match["expression"])
	
	puts "DEBUG: #{OMBI_URL}, #{OMBI_API_KEY}, #{query}"

	raw = HTTParty.get(
          "#{OMBI_URL}/api/v1/Search/movie/#{query}",
          {
            headers: {
              "ApiKey" => OMBI_API_KEY,
	    },
          }
        ).body

	puts raw

	body = JSON.parse(raw)

        build_message = -> {
          {
            channel: data.channel,
            text: "Showing first #{[MAX_RESULTS, body.size].min} of #{body.size} results for \"#{match["expression"]}\":",
            fallback: "use a full-featured slack client to use H8NET Bot",
            attachments: body.first(MAX_RESULTS).map do |movie|
              {
                title: "#{movie["title"]} (#{movie["releaseDate"][0..3]})",
                thumb_url: "https://image.tmdb.org/t/p/w300/#{movie["posterPath"]}",
                text: movie["overview"][0..200] + "...",
                callback_id: "movie_request",
                actions: [
                  {
                    name: "request",
                    text: "Request #{movie["title"]}",
                    type: "button",
                    value: movie["id"],
                  },
                ],
              }
            end,
          }
        }
        client.web_client.chat_postMessage(build_message.call)
      end

      command "tv" do |client, data, match|
        query = URI.escape(match["expression"])
        body = JSON.parse(HTTParty.get(
          "#{OMBI_URL}/api/v1/Search/tv/#{query}",
          {
            headers: {
              "ApiKey" => OMBI_API_KEY,
            },
          }
        ).body)

        build_message = -> {
          {
            channel: data.channel,
            text: "Showing first #{[MAX_RESULTS, body.size].min} of #{body.size} results for \"#{match["expression"]}\":",
            fallback: "use a full-featured slack client to use H8NET Bot",
            attachments: body.first(MAX_RESULTS).map do |tv|
              {
                title: "#{tv["title"]} (#{tv["firstAired"][0..3]})",
                thumb_url: "#{tv["banner"]}",
                text: tv["overview"][0..200] + "...",
                callback_id: "tv_request",
                actions: [
                  {
                    name: "request",
                    text: "Request #{tv["title"]}",
                    type: "button",
                    value: tv["id"],
                  },
                ],
              }
            end,
          }
        }
        client.web_client.chat_postMessage(build_message.call)
      end
    end
  end
end
