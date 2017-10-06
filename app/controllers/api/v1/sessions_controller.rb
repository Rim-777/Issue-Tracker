module Api::V1
  class SessionsController < BaseController
    before_action :authenticate_user! , only: :destroy
    before_action :set_user, only: :create

    def create
      if @user&.valid_password?(params[:password])
        render json: @user, serializer: UserSerializer, status: :created
      else
        head :unauthorized
      end
    end

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
