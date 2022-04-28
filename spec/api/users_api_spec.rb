require "rails_helper"

RSpec.describe UsersAPI do
  context "POST /api/users" do
    let(:user_params) do
      {
        name: "name",
        last_name: "last_name",
        birthday: "2022-04-29",
        phone_number: "phone_number",
        email: "email",
        usc_number: "usc_number",
      }
    end

    it "creates a user" do
      post "/api/users", params: { user: user_params }

      expect(response.status).to eq(201)
      expect(JSON.parse(response.body)).to be_nil
    end
  end
end
