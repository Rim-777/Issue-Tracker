module Api::V1
  class BaseController < ApplicationController
    acts_as_token_authentication_handler_for User, fallback: :none
    respond_to :json

    protected

    def authenticate_user!
      return if current_user
      head :unauthorized
    end
  end
end
