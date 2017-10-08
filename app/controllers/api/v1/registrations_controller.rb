module Api::V1
  class RegistrationsController < BaseController
    before_action :authenticate_user!, only: :destroy

    api :post, '/registrations', 'Create user'
    param :email, String, desc: 'User email', required: true
    param :password, String, desc: 'User password', required: true
    param :password_confirmation, String, desc: 'User password', required: true
    error code: 422, desc: 'Unprocessable entity'

    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, serializer: UserSerializer, status: :created
      else
        render json: @user.errors.full_messages.join(', '), status: 422
      end
    end

    api :delete, '/registrations', 'Delete user'
    header 'X-User-Token', 'Authentication token', required: true
    header 'X-User-Email', 'User email', required: true
    error code: 401, desc: :unauthorized

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
