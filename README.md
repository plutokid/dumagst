# Dumagst

This is my take at a simple recommendation system:
* given users and the products they like
* recommend those users some other products that they might like

# Implementation

* Jaccard similarity
* Minhashing to speed things up
* Similarity data are dumped in Redis so a recommendation can be obtained very fast
* Calculating similarities for 1682 products,943 users takes 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dumagst'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumagst

## Configuration

You should have a working redis server somewhere as this gem needs it to store similarity data. Configure the gem with

```ruby
require 'dumagst'

Dumagst.configure do |config|
  config.host = "localhost"
  config.port = 6379
  config.db = 1
  config.minimal_rating_for_like = 3
end
```

## Usage

### Generating similarity data

The [MovieLens 100K data](http://grouplens.org/datasets/movielens/) that I used as a sample can be found under data/ml-100k. To set it up:

```ruby
bundle exec ruby bin/prepare.csv      # generate the "like" data from the rating data 
```

To calculate jaccard similarites and store them in redis

```ruby
bundle exec ruby bin/calc_jaccard_similarities  
```

To calculate minhashed similarities and store them in redis

```ruby
bundle exec ruby bin/calc_minhash_similarities
```

### Using the data from your app
Note that you'll need to provide the correct engine key. That key is a part of redis key used to store similarities.


```ruby
  engine = Dumagst::Engines::JaccardEngine.new(engine_key: "jaccard_similarity")
  recommended_product_ids = engine.recommend_products(@user.id)
  recommended_user_ids = engine.recommend_users(@user.id)
```

```ruby
  engine = Dumagst::Engines::MinhashEngine.new(engine_key: "jaccard_minhash_similarity")
  recommended_product_ids = engine.recommend_products(@user.id)
  recommended_user_ids = engine.recommend_users(@user.id)
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/dumagst/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
