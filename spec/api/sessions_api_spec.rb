# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsAPI do
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
    end
  end
end
