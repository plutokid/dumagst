require 'redis'
require "dumagst/version"
require "dumagst/matrices/base"
require "dumagst/matrices/redis_matrix_mapper"
require "dumagst/matrices/redis_matrix"
require "dumagst/engines/base"
require "dumagst/engines/jaccard_similarity"
require "dumagst/engines/jaccard_engine"

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
