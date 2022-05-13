# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthday { Date.today }
    phone_number { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    usc_number { Faker::Number.number(digits: 10) }
    telegram_id { "123" } # seems to be the default when testing with telegram-bot helpers
  end
end
