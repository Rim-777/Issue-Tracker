module Api::V1
  class IssuesController < BaseController
    include Pundit
    before_action :authenticate_user!
    before_action :set_issue, except: [:index, :create]
    rescue_from Tracker::InvalidEventError, with: :handle_invalid_event

    def index
      collection = Issue.fetch_collection_by(user: current_user, state: params[:filter])
      @issues = paginate collection, per_page: params[:per_page]
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

    def assign
      authorize @issue
      if @issue.assign(current_user)
        render json: @issue, serializer: IssueSerializer
      else
        render json: @issue.errors.full_messages, status: 422
      end
    end

    def set_state
      authorize @issue
      if @issue.trigger_event(params[:state_event])
        render json: @issue, serializer: IssueSerializer
      else
        render json: @issue.errors.full_messages, status: 422
      end
    end

    private
    def issue_params
      params.require(:issue).permit(:title, :description)
    end

    def set_issue
      @issue = Issue.find(params[:id])
    end

    def handle_invalid_event(e)
      render json: {invalid_event_error: e.message}, status: 422
    end
  end
end
