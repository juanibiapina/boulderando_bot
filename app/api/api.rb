# frozen_string_literal: true

class API < Grape::API
  format :json

  rescue_from :all do |e|
    Sentry.capture_exception(e)
    error!({ error: e.message }, 500)
  end

  mount UsersAPI
end
