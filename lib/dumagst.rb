require 'redis'
require "dumagst/version"
require "dumagst/matrices/base"
require "dumagst/matrices/redis_matrix_mapper"
require "dumagst/matrices/redis_matrix"
require "dumagst/matrices/native_matrix"
require "dumagst/engines/base"
require "dumagst/engines/jaccard_similarity"
require "dumagst/engines/similar_product"
require "dumagst/engines/similar_user"
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
    attr_accessor :host, :port, :db, :score_scale, :minimal_rating_for_like

    def redis_connection
      @redis ||= Redis.new(host: host, port:port, db:db)
    end

    def score_scale
      @score_scale || 1000 #default
    end

    def score_scale=(score_scale)
      @score_scale = score_scale
    end

    def minimal_rating_for_like
      @minimal_rating_for_like || 3
    end

    def minimal_rating_for_like=(minimal_rating_for_like)
      @minimal_rating_for_like = minimal_rating_for_like
    end

  end

end
