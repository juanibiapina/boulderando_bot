source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# rails
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# database
gem "pg", "~> 1.1"

# server
gem "puma", "~> 5.0"

# telegram
gem "telegram-bot"

# http
gem "faraday"

# error reporting
gem "sentry-ruby"
gem "sentry-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails", "~> 5.0.0"
end
