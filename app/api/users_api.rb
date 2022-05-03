class UsersAPI < Grape::API
  format :json

  resource :users do
    desc 'Create a User.'
    params do
      requires :user, type: Hash do
        requires :name, type: String
        requires :last_name, type: String
        requires :birthday, type: Date
        requires :phone_number, type: String
        requires :email, type: String
        requires :usc_number, type: String
        requires :telegram_id, type: String
      end
    end
    post do
      user = User.find_or_initialize_by(telegram_id: params[:user][:telegram_id])

      user.name = params[:user][:name]
      user.last_name = params[:user][:last_name]
      user.birthday = params[:user][:birthday]
      user.phone_number = params[:user][:phone_number]
      user.email = params[:user][:email]
      user.usc_number = params[:user][:usc_number]

      user.save!

      nil
    end
  end
end
