require 'dumagst'

Dumagst.configure do |config|
  config.host = "localhost"
  config.port = 6379
  config.db = 1
  config.minimal_rating_for_like = 3
end
