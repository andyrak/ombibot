require "sinatra/base"
require "uri"
require "httparty"
HTTParty::Basement.default_options.update(verify: false)

OMBI_URL = ENV["OMBI_URL"]
OMBI_API_KEY = ENV["OMBI_API_KEY"]

module OmbiBot
  class Web < Sinatra::Base
    get "/" do
      "Ain't ever googled a goddamn thing."
    end
    
    post "/" do
      body = JSON.parse(URI.decode(request.body.read)[8..-1])
      type = body["callback_id"]
      response_url = body["response_url"]

      # spawn a new thread to push the request into ombi
      Thread.new do
        if type == "movie_request"
          begin
            body = {
              "theMovieDbId" => body["actions"][0]["value"].to_i,
              "languageCode" => "en",
            }.to_json
            
            res = HTTParty.post(
              "#{OMBI_URL}/api/v1/Request/movie",
              headers: {"ApiKey" => OMBI_API_KEY, "Content-Type" => "application/json"},
              body: body,
            )
            
            delayed_resp = res.parsed_response["message"]

            HTTParty.post(
              response_url,
              body: {
                "text" => delayed_resp
              }.to_json
            )
          rescue => exception
            puts "exception: " + exception.to_s
          
          end
        elsif type == "tv_request"
          begin
            body = {
              "tvDbId" => body["actions"][0]["value"].to_i,
              "requestAll": true,
            }.to_json
            
            res = HTTParty.post(
              "#{OMBI_URL}/api/v1/Request/tv",
              headers: {"ApiKey" => OMBI_API_KEY, "Content-Type" => "application/json"},
              body: body,
            )
            
            delayed_resp = res.parsed_response["message"]
          
            HTTParty.post(
              response_url,
              body: {
                "text" => delayed_resp
              }.to_json
            )
          rescue => exception
            puts "exception: " + exception.to_s
          
          end
        end
        Thread.kill
      end

      # The immediate response to the user that their request was successful
      HTTParty.post(
        response_url,
        body: {
          "text" => "_Beeping the boops into H8NET..._ :andy:",
          "response_type" => "in_channel"
        }.to_json
      )

    end
  end
end
