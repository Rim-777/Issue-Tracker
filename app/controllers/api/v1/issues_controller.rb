module Api::V1
  class IssuesController < BaseController
    include Pundit
    before_action :authenticate_user!
    before_action :set_issue, except: [:index, :create]
    rescue_from Tracker::InvalidEventError, with: :handle_invalid_event

    def_param_group :issue do
      param 'title', String,  desc: 'Title of an issue', required: true
      param 'description', String,  desc: 'Description of an issue', required: true
    end

    def_param_group :issue_id_errors do
      param :id, Fixnum, desc: 'Id for getting of an issue', required: true
      error code: 422, desc: 'unprocessible entity'
    end

    api :get, '/issues',  'List of Issues'
    param_group :headers
    param :filter, String, desc: 'State of issues to filter'
    param :per_page, Fixnum, desc: 'Number of pages for the pagination'

    def index
      collection = Issue.fetch_collection_by(user: current_user, state: params[:filter])
      @issues = paginate collection, per_page: params[:per_page]
      respond_with :api, @issues
    end

    api :post, '/issues',  'Create Issues'
    param_group :headers
    param_group :issue

    def create
      authorize Issue
      @issue = current_user.issues.create(issue_params)
      respond_with :api, @issue
    end

    api :get, '/issues/:id',  'Show an Issue'
    param_group :headers
    param :id, Fixnum, desc: 'Id for getting of an issue', required: true

    def show
      authorize @issue
      respond_with :api, @issue
    end

    api :patch, '/issues/:id',  'Update an Issue'
    param_group :headers
    param_group :issue
    param_group :issue_id_errors

    def update
      authorize @issue
      if @issue.update(issue_params)
        render json: @issue, serializer: IssueSerializer
      else
        render json: @issue.errors.full_messages, status: 422
      end
    end

    api :delete, '/issues/:id', 'Delete an Issue'
    param_group :headers
    param :id, Fixnum, desc: 'Id for getting of an Issue', required: true

    def destroy
      authorize @issue
      @issue.destroy
      head :ok
    end

    api :patch, '/issues/:id/assign', 'Assign an Issue to your self'
    param_group :headers
    param_group :issue_id_errors

    def assign
      authorize @issue
      if @issue.assign(current_user)
        render json: @issue, serializer: IssueSerializer
      else
        render json: @issue.errors.full_messages, status: 422
      end
    end

    api :patch, '/issues/:id/set_state', 'Change state of an issue'
    param_group :headers
    param_group :issue_id_errors
    param :state_event, String, required: true,
          desc: 'allowed: open_issue, in_progress, close_issue, stop_issue'

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
