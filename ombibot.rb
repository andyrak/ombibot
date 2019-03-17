require "slack-ruby-bot"
require "ombibot/commands/request"
require "ombibot/bot"

SlackRubyBot.configure do |config|
  config.aliases = ["request"]
end
