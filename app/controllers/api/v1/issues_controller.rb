module Api::V1
  class IssuesController < BaseController
    include Pundit
    before_action :authenticate_user!
    before_action :set_issue, except: [:index, :create]

    def index
      @issues = current_user.has_role?(:manager) ? Issue.all : current_user.issues
      respond_with :api, @issues
    end

    def create
      authorize Issue
      @issue = current_user.issues.create(issue_params)
      respond_with :api, @issue
    end

    def show
      authorize @issue
      respond_with :api, @issue
    end

    def update
      authorize @issue
      if @issue.update(issue_params)
        render json: @issue, serializer: IssueSerializer
      else
        render json: @issue.errors.full_messages, status: 422
      end
    end

    def destroy
      authorize @issue
      @issue.destroy
      head :ok
    end

    private
    def issue_params
      params.require(:issue).permit(:title, :description)
    end

    def set_issue
      @issue = Issue.find(params[:id])
    end
  end
end
