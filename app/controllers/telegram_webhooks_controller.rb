# frozen_string_literal: true

require 'scheduler'

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

  def callback_query(data)
    user = User.find_by(telegram_id:)

    if user.nil?
      respond_with :message, text: "Hi #{mention}, I don't know you yet. DM please."
    else
      session = ::Session.find(data)

      booking = $redis.get("booking:#{user.id}:#{session.id}") # rubocop:disable Style/GlobalVars
      if booking == 'true'
        return
      end

      $redis.set("booking:#{user.id}:#{session.id}", 'true', ex: 60.seconds) # rubocop:disable Style/GlobalVars

      booked = schedule(
        user,
        {
          gym_name: session.gym_name,
          human_date: session.date.iso8601,
          time: session.time,
        }
      )

      if booked
        bot.edit_message_text(
          message_id: payload['message']['message_id'],
          chat_id: BOULDERANDO_CHAT_ID,
          text: payload['message']['text'] + "\n#{from['first_name']}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: 'Join', callback_data: session.id,
              }
            ]],
          }
        )
        respond_with :message, text: "#{mention} You're in"
      else
        respond_with :message, text: "#{mention} Failed to join. There may be a problem or no more available spots"
      end
    end
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

  def schedule(user, session, dry_run: false)
    # calculate day
    date = Chronic.parse(session[:human_date])
    day = date.day.to_s
    month = date.month

    case session[:gym_name]
    when 'basement'
      Scheduler.new.schedule_basement(user, day, month, session[:time], submit: !dry_run)
    when 'boulderklub'
      Scheduler.new.schedule_boulderklub(user, day, month, session[:time], submit: !dry_run)
    end

    true
  end

  def handle_standard_error(e)
    Sentry.capture_exception(e)
    respond_with :message, text: 'Sorry, there was an error somewhere.'
  end
end
