# frozen_string_literal: true
Rails.application.routes.draw do
  mount API => "/api"

  telegram_webhook TelegramWebhooksController
end
