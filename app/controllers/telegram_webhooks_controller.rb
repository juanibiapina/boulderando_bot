class TelegramWebhooksController < Telegram::Bot::UpdatesController
  def start!(*)
    respond_with :message, text: "Hi"
  end

  def schedule!(*words)
    parts = words.join(" ").split(",")

    user = {
      name: parts[0],
      last_name: parts[1],
      birthday: parts[2],
      address: parts[3],
      postal_code: parts[4],
      city: parts[5],
      phone_number: parts[6],
      email: parts[7],
      type: "Urban Sports Club",
      usc_number: parts[8],
    }

    session = {
      gym_name: parts[9],
      human_date: parts[10],
      time: parts[11],
    }

    dry_run = true

    conn = Faraday.new(
      url: "https://murmuring-caverns-56233.herokuapp.com",
      headers: {'Content-Type' => 'application/json'}
    )

    response = conn.post('/sessions') do |req|
      req.body = {
        user: user,
        session: session,
        dry_run: dry_run,
      }.to_json
    end

    respond_with :message, text: response.body
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message, text: "Command not found: #{action_options[:command]}"
    end
  end
end
