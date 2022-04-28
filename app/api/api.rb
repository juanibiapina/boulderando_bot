# frozen_string_literal: true

class API < Grape::API
  format :json

  rescue_from :grape_exceptions

  mount UsersAPI
end
