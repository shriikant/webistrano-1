source "https://rubygems.org"

gem "rails", "3.2.9"

gem "exception_notification"

gem "capistrano"
gem "open4"
gem "syntax"
gem "version_fu", :github => "jmckible/version_fu"
gem "devise"
gem "devise-encryptable"
gem "libv8"

group :development do
  gem "sqlite3"
  gem "thin"

  gem "debugger"
  gem "pry"
  gem "pry-rails"
end

group :test do
  gem "sqlite3"
  gem "test-unit"
  gem "mocha", "0.12.7"
  gem "factory_girl_rails"
  gem "database_cleaner"
end

group :production do
  gem "pg"
  gem "unicorn"
end

group :assets do
  gem 'therubyracer'
  gem 'uglifier'
  gem "jquery-rails"
end
