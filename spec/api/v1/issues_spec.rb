require 'rails_helper'

describe 'Issues API' do
  let!(:user) {create(:user)}

  describe 'GET :index' do
    let!(:regular_user_issue_list) {create_list(:issue, 2, user: user)}
    let(:request) {get '/api/issues', params: {}, headers: headers, xhr: true}

    context 'authenticated' do
      context 'regular user' do
        let(:headers) do
          {
              'X-User-Token' => user.authentication_token,
              'X-User-Email' => user.email,
              "HTTP_ACCEPT" => "application/json"
          }
        end

        it 'returns status :ok' do
          request
          expect(response).to be_success
        end

        it 'returns json with an array' do
          request
          expect(response.body).to have_json_size(2).at_path('/')
        end

        it 'returns an array of issues' do
          request
          regular_user_issue_list.each do |issue|
            expect(response.body).to include_json(issue.to_json).excluding('assignee_id').at_path('/')
          end
        end

        it 'returns json according schema' do
          request
          expect(response).to match_response_schema('un_assigned_issues')
        end
      end

      context 'manager' do
        let(:manager) {create(:user)}
        let!(:regular_user_issue_list) {create_list(:issue, 2, user: user, assignee: manager)}
        let!(:manager_issue_list) {create_list(:issue, 2, user: manager, assignee: manager)}

        let(:headers) do
          {
              'X-User-Token' => manager.authentication_token,
              'X-User-Email' => manager.email,
              "HTTP_ACCEPT" => "application/json"
          }
        end

        before {manager.add_role(:manager)}

        it 'returns json with an array' do
          request
          expect(response.body).to have_json_size(4).at_path('/')
        end

        it 'returns an array of all issues' do
          request
          manager_issue_list.concat(regular_user_issue_list).each do |issue|
            expect(response.body).to include_json(issue.to_json).at_path('/')
          end
        end

        it 'returns json according schema' do
          request
          expect(response).to match_response_schema('assigned_issues')
        end
      end
    end

    context 'unauthenticated' do
      context 'wrong authentication_token' do
        let(:headers) do
          {
              'X-User-Token' => 'wrong-token',
              'X-User-Email' => user.email,
              "HTTP_ACCEPT" => "application/json"
          }
        end

        it_behaves_like 'UnAuthenticatedUser'
      end

      context 'wrong email' do
        let(:headers) do
          {
              'X-User-Token' => user.authentication_token,
              'X-User-Email' => 'fake@email.com',
              "HTTP_ACCEPT" => "application/json"
          }
        end

        it_behaves_like 'UnAuthenticatedUser'
      end
    end
  end
end
