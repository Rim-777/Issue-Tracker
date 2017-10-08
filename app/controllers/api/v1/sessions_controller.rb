module Api::V1
  class SessionsController < BaseController
    before_action :authenticate_user! , only: :destroy
    before_action :set_user, only: :create

    api :post, '/sessions', 'Sign In'
    param :email, String, desc: 'User email', required: true
    param :password, String, desc: 'User password', required: true
    error code: 401, desc: :unauthorized

    def create
      if @user&.valid_password?(params[:password])
        render json: @user, serializer: UserSerializer, status: :created
      else
        head :unauthorized
      end
    end

    api :delete, '/sessions', 'Sign Out'
    param_group :headers

    def destroy
      if current_user.update(authentication_token: nil)
        head(:ok)
      else
        render json: @user.errors.full_messages.join(', '), status: 422
      end
    end

    private

    def set_user
      @user = User.find_by_email(params[:email])
    end
  end
end
