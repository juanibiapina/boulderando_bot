# frozen_string_literal: true

require "scheduler"

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session

  BOULDERANDO_CHAT_ID = -1001696947067

  rescue_from StandardError, with: :handle_standard_error

  def start!
    respond_with :message, text: I18n.t("help")
  end

  def help!
    respond_with :message, text: I18n.t("help", registration_link: registration_link)
  end

  def privacy_policy!
    respond_with :message, text: I18n.t("privacy_policy")
  end

  def get_user_info!
    user = User.find_by(telegram_id: telegram_id)

    if user.present?
      respond_with :message, text: "User info:
name: #{user.name}
last_name: #{user.last_name}
birthday: #{user.birthday.strftime("%d.%m.%Y")}
phone_number: #{user.phone_number}
email: #{user.email}
usc_number: #{user.usc_number}
"
    else
      respond_with :message, text: "No user info saved."
    end
  end

  def set_user_info!(*words)
    parts = words.join(" ").split(",")

    user = User.find_or_initialize_by(telegram_id: telegram_id).tap do |user|
      user.name = parts[0]
      user.last_name = parts[1]
      user.birthday = Date.parse(parts[2])
      user.phone_number = parts[3]
      user.email = parts[4]
      user.usc_number = parts[5]
    end

    user.save!

    respond_with :message, text: "User info saved:
name: #{user.name}
last_name: #{user.last_name}
birthday: #{user.birthday.strftime("%d.%m.%Y")}
phone_number: #{user.phone_number}
email: #{user.email}
usc_number: #{user.usc_number}
"
  end

  def delete_user_info!
    User.find_by(telegram_id: telegram_id).destroy!

    respond_with :message, text: "User info deleted"
  end

  def publish!(*words)
    user = User.find_by(telegram_id: telegram_id)

    if user.nil?
      respond_with :message, text: "Sorry #{mention}, I don't know you yet. DM please."
    else
      parts = words.join(" ").split(",").map(&:strip)

      session = {
        gym_name: parts[0],
        human_date: parts[1],
        time: parts[2],
      }

      booked = schedule(user, session, dry_run: true)

      if booked
        bot.send_message(
          chat_id: BOULDERANDO_CHAT_ID,
          text: "🧗🧗🧗 Session: #{session[:gym_name]}, #{session[:human_date]}, #{session[:time]}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: "Join", callback_data: "join",
              }
            ]],
          }
        )
      else
        respond_with :message, text: "Failed to join"
      end
    end
  end

  def callback_query(data)
    user = User.find_by(telegram_id: telegram_id)

    if user.nil?
      respond_with :message, text: "Hi #{mention}, I don't know you yet. DM please."
    else
      parts = payload["message"]["text"].split("\n")[0][13..-1].split(",").map(&:strip)

      session = {
        gym_name: parts[0],
        human_date: parts[1],
        time: parts[2],
      }

      booked = schedule(user, session)

      if booked
        bot.edit_message_text(
          message_id: payload["message"]["message_id"],
          chat_id: BOULDERANDO_CHAT_ID,
          text: payload["message"]["text"] + "\n#{from["first_name"]}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: "Join", callback_data: "join",
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

  def schedule!(*words)
    user = User.find_by(telegram_id: telegram_id)

    if user.nil?
      respond_with :message, text: "Sorry #{mention}, I don't know you yet. DM please."
    else
      parts = words.join(" ").split(",").map(&:strip)

      session = {
        gym_name: parts[0],
        human_date: parts[1],
        time: parts[2],
      }

      schedule(user, session, dry_run: true)
      respond_with :message, text: "Booked"
    end
  end

  def action_missing(action, *_args)
    return unless action_type == :command

    respond_with :message, text: "Command not found: #{action_options[:command]}"
  end

  private

  def telegram_id
    @telegram_id ||= from["id"]
  end

  def mention
    @mention ||= if from["username"].present?
                   "@#{from["username"]}"
                 else
                   from["first_name"]
                 end
  end

  def schedule(user, session, dry_run: false)
    # calculate day
    date = Chronic.parse(session[:human_date])
    day = date.day.to_s
    month = date.month

    case session[:gym_name]
    when "basement"
      Scheduler.new.schedule_basement(user, day, month, session[:time], submit: !dry_run)
    when "boulderklub"
      Scheduler.new.schedule_boulderklub(user, day, month, session[:time], submit: !dry_run)
    end

    true
  end

  def handle_standard_error(e)
    Sentry.capture_exception(e)
    respond_with :message, text: "Sorry, there was an error somewhere."
  end

  def registration_link
    "https://boulderando.vercel.app/user/new?redirect_to=https%3A%2F%2Ft.me%2FBoulderandoBot&telegram_id=#{telegram_id}"
  end
end
