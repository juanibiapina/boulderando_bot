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

      expect(User.count).to eq(1)
      user = User.last
      expect(user.name).to eq("name")
      expect(user.last_name).to eq("last_name")
      expect(user.birthday).to eq(Date.parse("2022-04-29"))
      expect(user.phone_number).to eq("phone_number")
      expect(user.email).to eq("email")
      expect(user.usc_number).to eq("usc_number")
    end
  end
end
