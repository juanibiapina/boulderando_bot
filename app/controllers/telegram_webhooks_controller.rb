class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session

  BOULDERANDO_CHAT_ID = -1001696947067

  def start!(*)
    respond_with :message, text: help_text
  end

  def help!(*)
    respond_with :message, text: help_text
  end

  def set_user_info!(*words)
    parts = words.join(" ").split(",")

    user = User.find_or_initialize_by(telegram_id: telegram_id).tap do |user|
      user.name = parts[0]
      user.last_name = parts[1]
      user.birthday = parts[2]
      user.address = parts[3]
      user.postal_code = parts[4]
      user.city = parts[5]
      user.phone_number = parts[6]
      user.email = parts[7]
      user.usc_number = parts[8]
    end

    user.save!

    respond_with :message, text: "User info saved:
name: #{user.name}
last_name: #{user.last_name}
birthday: #{user.birthday}
address: #{user.address}
postal_code: #{user.postal_code}
city: #{user.city}
phone_number: #{user.phone_number}
email: #{user.email}
usc_number: #{user.usc_number}
"
  end

  def delete_user_info!(*)
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

      response = call_scheduling_api(user, session, dry_run: true)

      if response.success?
        bot.send_message(
          chat_id: BOULDERANDO_CHAT_ID,
          text: "🧗🧗🧗 Session: #{session[:gym_name]}, #{session[:human_date]}, #{session[:time]}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: "Join", callback_data: "saf"
              }
            ]]
          }
        )
      else
        respond_with :message, text: "Failed to book: #{response.body}"
      end
    end
  end

  def callback_query(data)
    user = User.find_by(telegram_id: telegram_id)

    if user.nil?
      bot.answer_callback_query(callback_query_id: payload["id"], text: "I don't know you yet. DM please.")
    else
      parts = payload["message"]["text"].split("\n")[0][13..-1].split(",").map(&:strip)

      session = {
        gym_name: parts[0],
        human_date: parts[1],
        time: parts[2],
      }

      response = call_scheduling_api(user, session)

      if response.success?
        bot.edit_message_text(
          message_id: payload["message"]["message_id"],
          chat_id: BOULDERANDO_CHAT_ID,
          text: payload["message"]["text"] + "\n#{from["first_name"]}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: "Join", callback_data: "join"
              }
            ]]
          }
        )
        bot.answer_callback_query(callback_query_id: payload["id"], text: "You're in")
      else
        bot.answer_callback_query(callback_query_id: payload["id"], text: "Failed to Join :(")
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

      response = call_scheduling_api(user, session)

      if response.success?
        respond_with :message, text: response.body
      else
        respond_with :message, text: "Failed to book: #{response.body}"
      end
    end
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message, text: "Command not found: #{action_options[:command]}"
    end
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

  def help_text
    "Commands:
/help : Shows this help text
/set_user_info <pattern> : Saves your info for future scheduling
/delete_user_info: Delete your info

<pattern>: first name, last name, birthday (dd.mm.yyyy), address, postal code, city, phone number, email, urban sports club number"
  end

  def call_scheduling_api(user, session, dry_run: false)
    conn = Faraday.new(
      url: "https://murmuring-caverns-56233.herokuapp.com",
      headers: {'Content-Type' => 'application/json'}
    )

    conn.post('/sessions') do |req|
      req.body = {
        user: {
          name: user.name,
          last_name: user.last_name,
          birthday: user.birthday,
          address: user.address,
          postal_code: user.postal_code,
          city: user.city,
          phone_number: user.phone_number,
          email: user.email,
          type: "Urban Sports Club",
          usc_number: user.usc_number,
        },
        session: session,
        dry_run: dry_run,
      }.to_json
    end
  end
end
