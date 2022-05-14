# frozen_string_literal: true

require 'scheduler'

class SessionsAPI < Grape::API
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
    end
  end
end