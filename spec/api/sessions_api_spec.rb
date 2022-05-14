# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsAPI do
  let(:scheduler_instance) { double(Scheduler) }
  let(:user) { create(:user) }

  before do
    allow(Scheduler).to receive(:new).and_return(scheduler_instance)
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
        gym_name: "basement",
        human_date: "22.03.2022",
        time: "18:30 - 20:30",
      }
    end

    it "calls scheduler to schedule a session" do
      allow(scheduler_instance).to receive(:schedule_basement)

      post "/api/sessions", params: { user: user_params, session: session_params }

      expect(response.status).to eq(201)
      expect(scheduler_instance).to have_received(:schedule_basement).with(user, "22", 3, "18:30 - 20:30", submit: true)
      expect(JSON.parse(response.body)).to be_nil
    end
  end
end
