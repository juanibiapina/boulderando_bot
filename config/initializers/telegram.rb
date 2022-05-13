# frozen_string_literal: true

Telegram.bots_config = {
  default: ENV.fetch('TELEGRAM_BOT_TOKEN'),
}
