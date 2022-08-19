# frozen_string_literal: true

require 'rails_helper'
require 'telegram/bot/rspec/integration/rails'

RSpec.describe TelegramWebhooksController, type: :request, telegram_bot: :rails do
  describe 'commands' do
    describe 'help' do
      it 'replies with help text' do
        expect { dispatch_command(:help) }.to make_telegram_request(bot, :sendMessage)
      end
    end
  end
end
