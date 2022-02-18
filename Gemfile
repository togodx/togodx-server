source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'rails', '~> 6.1.3', '>= 6.1.3.2'

# application cache
gem 'bootsnap', '>= 1.4.4', require: false

# database
# gem 'pg', '~> 1.2'
gem 'sqlite3', '~> 1.4'
# gem 'redis', '~> 4.0'

# rack / rack middleware
gem 'puma', '~> 5.0'
gem 'rack-cors', '~> 1.1'

# http client
gem 'faraday', '~> 1.7'
gem 'net-http-persistent', '~> 4.0'

# extension
gem 'active_interaction', '~> 4.0'
gem 'awesome_nested_set', '~> 3.4'
gem 'activerecord-import', '~> 1.2', require: false
gem 'dotenv-rails', '~> 2.7'
gem 'rails_pretty_json_rednerer', '~> 0.1.0'
gem 'rubystats', '~> 0.3.0'

# template engine
gem 'jbuilder', '~> 2.11'

# command-line interface
gem 'thor', '~> 1.1'

# utility
gem 'rubyzip', '~> 2.3'

# console
gem 'pry-rails', '~> 0.3.9'

group :development, :test do
  gem 'pry-byebug', '~> 3.9'
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'listen', '~> 3.7'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
