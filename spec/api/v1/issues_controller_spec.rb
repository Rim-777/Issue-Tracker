require 'rails_helper'

describe 'Issues API' do
  let!(:user) {create(:user)}
  describe 'GET :index' do
    let!(:regular_user_issue_list) {create_list(:issue, 2, user: user)}
    let(:request) {get '/api/issues', params: {}, headers: headers, xhr: true}

    context 'authenticated' do
      context 'regular user' do
        let_valid_headers

        before {request}

        it_behaves_like 'Success'

        it 'returns json with an array' do
          expect(response.body).to have_json_size(2).at_path('/')
        end

        it 'returns an array of issues' do
          regular_user_issue_list.each do |issue|
            expect(response.body).to include_json(issue.to_json).at_path('/')
          end
        end

        it 'returns json according to the schema' do
          expect(response).to match_response_schema('un_assigned_issues')
        end
      end

      context 'manager' do
        let(:manager) {create(:user)}
        let!(:regular_user_issue_list) {create_list(:issue, 2, user: user, assignee: manager)}
        let!(:manager_issue_list) {create_list(:issue, 2, user: manager, assignee: user)}

        let(:headers) do
          {
              'X-User-Token' => manager.authentication_token,
              'X-User-Email' => manager.email,
              "HTTP_ACCEPT" => "application/json"
          }
        end

        before do
          manager.add_role(:manager)
          request
        end

        it 'returns json with an array' do
          expect(response.body).to have_json_size(4).at_path('/')
        end

        it 'returns an array of all issues' do
          manager_issue_list.concat(regular_user_issue_list).each do |issue|
            expect(response.body).to include_json(issue.to_json).at_path('/')
          end
        end

        it 'returns json according to the schema' do
          expect(response).to match_response_schema('assigned_issues')
        end
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticated'
    end
  end

  describe 'POST :create' do
    let(:params) {{issue: {title: 'The Issue Title', description: 'The Issue Description'}}}
    let(:request) {post '/api/issues', params: params, headers: headers, xhr: true}

    context 'authenticated' do
      let_valid_headers

      it_behaves_like 'Success'

      it 'records a new issue into database' do
        expect {request}.to change(Issue, :count).by(1)
      end

      it 'records a new issue into database related to the user' do
        expect {request}.to change(user.issues, :count).by(1)
      end

      it 'returns json with assigned values' do
        request
        params[:issue].each {|k, v| expect(response.body).to be_json_eql(v.to_json).at_path(k.to_s)}
      end

      it 'returns json according to the schema' do
        request
        expect(response).to match_response_schema('un_assigned_issue')
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticatedAndUnChanged'
    end
  end

  describe 'GET :show' do
    let!(:issue) {create(:issue, user: user)}
    let(:request) {get "/api/issues/#{issue.id}", params: {}, headers: headers, xhr: true}
    context 'authenticated' do
      let_valid_headers

      before {request}
      it_behaves_like 'Success'

      it 'returns an issue as json' do
        expect(response.body).to be_json_eql(issue.to_json).at_path('/')
      end

      it 'returns json according to the schema' do
        expect(response.body).to match_response_schema('un_assigned_issue')
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticated'
    end
  end

  describe 'PATCH :update' do
    let!(:issue) {create(:issue, user: user, title: 'The old Issue Title', description: 'The old Issue Description')}
    let(:params) {{issue: {title: 'The New Issue Title', description: 'The New Issue Description'}}}
    let(:request) {patch "/api/issues/#{issue.id}", params: params, headers: headers, xhr: true}

    context 'authenticated' do
      let_valid_headers

      it_behaves_like 'Success'

      it "doesn't change an issues count" do
        expect {request}.to_not change(Issue, :count)
      end

      it 'returns json with assigned values' do
        request
        params[:issue].each {|k, v| expect(response.body).to be_json_eql(v.to_json).at_path(k.to_s)}
      end

      it 'returns json according to the schema' do
        request
        expect(response.body).to match_response_schema('un_assigned_issue')
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticatedAndUnUpdated'
    end
  end

  describe 'DELETE :destroy' do
    let!(:issue) {create(:issue, user: user)}
    let(:request) {delete "/api/issues/#{issue.id}", params: {}, headers: headers, xhr: true}

    context 'authenticated' do
      let_valid_headers

      it_behaves_like 'Success'

      it 'remove an issue from the database' do
        expect {request}.to change(Issue, :count).by(-1)
      end
      it 'remove an issue from the database related to the user' do
        expect {request}.to change(user.issues, :count).by(-1)
      end

      it 'returns empty response body' do
        request
        expect(response.body).to be_empty
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticatedAndUnChanged'
    end
  end

  describe 'PATCH :assign' do
    let(:request) {patch "/api/issues/#{issue.id}/assign", params: {}, headers: headers, xhr: true}
    before {user.add_role :manager}
    context 'authenticated' do
      let_valid_headers
      before {request}

      context 'the issue is not assigned' do
        let!(:issue) {create(:issue, user: user)}

        it_behaves_like 'Success'

        it 'returns an issue as json' do
          issue.reload
          expect(response.body).to be_json_eql(issue.to_json).at_path('/')
        end

        it 'returns json according to the schema' do
          issue.reload
          expect(response.body).to match_response_schema('assigned_issue')
        end
      end

      context 'the issue is assigned' do
        let!(:issue) {create(:issue, user: user, assignee: user)}

        it_behaves_like 'Success'

        it 'returns an issue as json' do
          issue.reload
          expect(response.body).to be_json_eql(issue.to_json).at_path('/')
        end

        it 'returns json according to the schema' do
          expect(response.body).to match_response_schema('un_assigned_issue')
        end
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticatedAndUnAssigned'
    end
  end

  describe 'PATCH :set_state' do
    let!(:issue) {create(:issue, user: user, assignee: create(:user))}
    let(:request) {patch "/api/issues/#{issue.id}/set_state", params: params, headers: headers, xhr: true}

    before {user.add_role :manager}

    context 'authenticated' do
      let_valid_headers

      %w(open_issue stop_issue return_issue close_issue).each do |event|
        let(:params) {{state_event: event}}

        before {request}

        it_behaves_like 'Success'

        it 'returns an issue as json' do
          issue.reload
          expect(response.body).to be_json_eql(issue.to_json).at_path('/')
        end

        it 'returns json according to the schema' do
          expect(response.body).to match_response_schema('assigned_issue')
        end
      end
    end

    context 'unauthenticated' do
      it_behaves_like 'UnAuthenticatedAndUnStated'
    end
  end
end
