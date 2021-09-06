source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'rails', '~> 6.1.3', '>= 6.1.3.2'

# application cache
gem 'bootsnap', '>= 1.4.4', require: false

# database
gem 'sqlite3', '~> 1.4'
# gem 'redis', '~> 4.0'

# rack / rack middleware
gem 'puma', '~> 5.0'
gem 'rack-cors', '~> 1.1'

# extension
gem 'awesome_nested_set', '~> 3.4'
gem 'activerecord-import', '~> 1.2', require: false
gem 'rails_pretty_json_rednerer', '~> 0.1.0'

# template engine
gem 'jbuilder', '~> 2.11'

# console
gem 'pry-rails', '~> 0.3.9'

group :development, :test do
  gem 'pry-byebug', '~> 3.9'
end

group :development do
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'listen', '~> 3.7'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
