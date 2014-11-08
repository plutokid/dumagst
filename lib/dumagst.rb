require 'redis'
require "dumagst/version"
require "dumagst/redis_key_mapper"
require "dumagst/matrix"

module Dumagst
  # Your code goes here...

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(self.configuration)
  end

  def self.reset_configuration!
    self.configuration = Configuration.new
  end

  class Configuration
    attr_accessor :host, :port, :db

    def redis_connection
      @redis ||= Redis.new(host: host, port:port, db:db)
    end

  end

end
