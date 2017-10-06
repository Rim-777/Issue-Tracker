module Api::V1
  class RegistrationsController < BaseController
    before_action :authenticate_user!, only: :destroy

    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, serializer: UserSerializer, status: :created
      else
        render json: @user.errors.full_messages.join(', '), status: 422
      end
    end

    def destroy
      current_user.destroy
      head :ok
    end

    private
    def user_params
      params.require(:registration).permit(
          :email,
          :password,
          :password_confirmation
      )
    end
  end
end
