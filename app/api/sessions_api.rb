# frozen_string_literal: true

require 'scheduler'

class SessionsAPI < Grape::API
  BOULDERANDO_CHAT_ID = -1001696947067

  resource :sessions do
    desc 'Create a session.'
    params do
      requires :user, type: Hash do
        requires :telegram_id, type: String
        requires :email, type: String
      end
      requires :session, type: Hash do
        requires :gym_name, type: String
        requires :human_date, type: String
        requires :time, type: String
      end
      optional :dry_run, type: Boolean, default: false
    end
    post do
      gym_name = params['session']['gym_name']
      human_date = params['session']['human_date']
      time = params['session']['time']

      user = User.find_by(telegram_id: params['user']['telegram_id'], email: params['user']['email'])

      dry_run = params['dry_run']

      # calculate day
      date = Chronic.parse(human_date)
      day = date.day.to_s
      month = date.month

      case gym_name
      when 'basement'
        Scheduler.new.schedule_basement(user, day, month, time, submit: !dry_run)
      when 'boulderklub'
        Scheduler.new.schedule_boulderklub(user, day, month, time, submit: !dry_run)
      end

      if dry_run
        return {
          session: {
            id: 123,
            gym_name:,
            date: date.to_date.iso8601,
            time:,
          },
        }
      end

      session = Session.find_by(gym_name:, date:, time:)
      if session.nil?
        session = Session.create!(
          gym_name:,
          date:,
          time:,
          user:
        )

        Telegram.bot.send_message(
          chat_id: BOULDERANDO_CHAT_ID,
          text: "🧗🧗🧗 #{session.gym_name.capitalize}, #{session.date.strftime('%A, %B %d')}, #{session.time}\nParticipants:\n#{user.name}",
          reply_markup: {
            inline_keyboard: [[
              {
                text: 'Join', callback_data: session.id,
              }
            ]],
          }
        )
      end

      {
        session: {
          id: session.id,
          gym_name: session.gym_name,
          date: session.date.iso8601,
          time: session.time,
        },
      }
    end
  end
end
