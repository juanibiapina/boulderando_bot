# frozen_string_literal: true

require "rails_helper"
require "telegram/bot/rspec/integration/rails"

RSpec.describe SessionsAPI, telegram_bot: :rails  do
  let(:scheduler_instance) { double(Scheduler) }
  let(:user) { create(:user) }
  let(:gym_name) { 'basement' }
  let(:human_date) { '22.03.2022' }
  let(:time) { '18:30 - 20:30' }
  let(:date) { Date.parse(human_date) }

  before do
    allow(Scheduler).to receive(:new).and_return(scheduler_instance)
    allow(scheduler_instance).to receive(:schedule_basement)
  end

  context "POST /api/sessions" do
    let(:user_params) do
      {
        telegram_id: user.telegram_id,
        email: user.email,
      }
    end

    let(:session_params) do
      {
        gym_name: gym_name,
        human_date: human_date,
        time: time,
      }
    end

    context "when a session doesn't exist yet for this gym, date and time" do
      context "when dry_run is disabled" do
        it "calls scheduler to schedule a session" do
          post "/api/sessions", params: { user: user_params, session: session_params }

          expect(response.status).to eq(201)
          expect(scheduler_instance).to have_received(:schedule_basement).with(user, "22", 3, time, submit: true)
        end

        it "creates a session" do
          post "/api/sessions", params: { user: user_params, session: session_params }

          expect(Session.count).to eq(1)
          created_session = Session.last
          expect(created_session.gym_name).to eq(gym_name)
          expect(created_session.date).to eq(date)
          expect(created_session.time).to eq(time)
          expect(created_session.user).to eq(user)
        end

        it "returns session information" do
          post "/api/sessions", params: { user: user_params, session: session_params }

          expect(JSON.parse(response.body)).to eq(
            "session" => {
              "id" => Session.last.id,
              "gym_name" => gym_name,
              "date" => date.iso8601,
              "time" => time,
            }
          )
        end

        it "publishes the session to telegram chat" do
          post "/api/sessions", params: { user: user_params, session: session_params }

          expect(bot.requests[:sendMessage].last).to eq(
            chat_id: SessionsAPI::BOULDERANDO_CHAT_ID,
            text: "🧗🧗🧗 Basement, Tuesday, March 22, #{time}",
            reply_markup: {
              inline_keyboard: [[
                {
                  text: "Join", callback_data: Session.last.id,
                }
              ]],
            }
          )
        end
      end

      context "when dry_run is enabled" do
        it "calls scheduler to schedule a session" do
          post "/api/sessions", params: { user: user_params, session: session_params, dry_run: true }

          expect(response.status).to eq(201)
          expect(scheduler_instance).to have_received(:schedule_basement).with(user, "22", 3, time, submit: false)
        end

        it "does not create a session" do
          post "/api/sessions", params: { user: user_params, session: session_params, dry_run: true }

          expect(Session.count).to eq(0)
        end

        it "returns session information" do
          post "/api/sessions", params: { user: user_params, session: session_params, dry_run: true }

          expect(JSON.parse(response.body)).to eq(
            "session" => {
              "id" => 123,
              "gym_name" => gym_name,
              "date" => date.iso8601,
              "time" => time,
            }
          )
        end

        it "does not publish the session on the telegram chat" do
          post "/api/sessions", params: { user: user_params, session: session_params, dry_run: true }

          expect(bot.requests[:sendMessage].count).to eq(0)
        end
      end
    end

    context "when a session already exists for this gym, date and time" do
      before do
        Session.create!(
          gym_name: gym_name,
          date: date,
          time: time,
          user: user
        )
      end

      it "calls scheduler to schedule a session" do
        post "/api/sessions", params: { user: user_params, session: session_params }

        expect(response.status).to eq(201)
        expect(scheduler_instance).to have_received(:schedule_basement).with(user, "22", 3, time, submit: true)
      end

      it "does not create a new session" do
        post "/api/sessions", params: { user: user_params, session: session_params }

        expect(Session.count).to eq(1)
        created_session = Session.last
        expect(created_session.gym_name).to eq(gym_name)
        expect(created_session.date).to eq(date)
        expect(created_session.time).to eq(time)
        expect(created_session.user).to eq(user)
      end

      it "returns session information" do
        post "/api/sessions", params: { user: user_params, session: session_params }

        expect(JSON.parse(response.body)).to eq(
          "session" => {
            "id" => Session.last.id,
            "gym_name" => gym_name,
            "date" => date.iso8601,
            "time" => time,
          }
        )
      end

      it "does not publish the session on the telegram chat" do
        post "/api/sessions", params: { user: user_params, session: session_params }

        expect(bot.requests[:sendMessage].count).to eq(0)
      end
    end
  end
end
