# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# web
gem 'grape'
gem 'rack-cors'
gem 'rails', '~> 7.0.2', '>= 7.0.2.3'

# database
gem 'pg', '~> 1.1'
gem 'redis'

# server
gem 'puma', '~> 5.0'

# telegram
gem 'telegram-bot'

# date parser
gem 'chronic'

# automation
gem 'capybara'
gem 'selenium-webdriver'

# error reporting
gem 'sentry-rails'
gem 'sentry-ruby'

group :development, :test do
  gem 'debug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'rubocop-base', require: false, github: 'juanibiapina/rubocop-base'
  gem 'rubocop-rails', require: false
end
