# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session

  BOULDERANDO_CHAT_ID = -1001696947067

  rescue_from StandardError, with: :handle_standard_error

  def start!
    respond_with :message, text: I18n.t('help')
  end

  def help!
    respond_with :message, text: I18n.t('help')
  end

  def schedule!(*words)
    parts = words.join(' ').split(',').map(&:strip)

    gym_name = parts[0]
    human_date = parts[1]
    time = parts[2]

    date = Chronic.parse(human_date)

    Telegram.bot.send_message(
      chat_id: BOULDERANDO_CHAT_ID,
      text: I18n.t('session',
                   gym_name: gym_name.capitalize,
                   date: date.strftime('%A, %B %d'),
                   time:,
                   users: nil),
      reply_markup: {
        inline_keyboard: [[
          {
            text: 'Join', callback_data: 'unused',
          }
        ]],
      }
    )

    respond_with :message, text: 'Session created in Boulderando Chat'
  end

  def callback_query(_data)
    bot.edit_message_text(
      message_id: payload['message']['message_id'],
      chat_id: BOULDERANDO_CHAT_ID,
      text: payload['message']['text'] + "\n#{from['first_name']}",
      reply_markup: {
        inline_keyboard: [[
          {
            text: 'Join', callback_data: 'unused',
          }
        ]],
      }
    )
    respond_with :message, text: "#{mention} You're in"
  end

  def action_missing(_action, *_args)
    return unless action_type == :command

    respond_with :message, text: "Command not found: #{action_options[:command]}"
  end

  private

  def telegram_id
    @telegram_id ||= from['id']
  end

  def mention
    @mention ||= if from['username'].present?
                   "@#{from['username']}"
                 else
                   from['first_name']
                 end
  end

  def handle_standard_error(e)
    Sentry.capture_exception(e)
  end
end
