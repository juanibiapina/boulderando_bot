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
      end
    end
    post do
    end
  end
end
