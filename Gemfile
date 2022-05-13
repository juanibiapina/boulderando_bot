source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# web
gem "rails", "~> 7.0.2", ">= 7.0.2.3"
gem "grape"
gem "rack-cors"

# database
gem "pg", "~> 1.1"

# server
gem "puma", "~> 5.0"

# telegram
gem "telegram-bot"

# date parser
gem "chronic"

# automation
gem "capybara"
gem "selenium-webdriver"

# error reporting
gem "sentry-ruby"
gem "sentry-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", "~> 5.0.0"
  gem "rubocop", require: false
  gem "rubocop-rails"
  gem "rubocop-rspec"
end
