require 'rails_helper'

describe 'Issues API' do
  describe 'POST :create' do
    context 'valid params' do
      let(:params) do
        {registration: {email: 'test@studytube.nl', password: '12345678', password_confirmation: '12345678'}}
      end

      let(:request) {post '/api/registrations', params: params, headers: {}, xhr: true}

      it 'returns status :ok' do
        request
        expect(response).to be_success
      end

      it 'records a new user into database' do
        expect {request}.to change(User, :count).by(1)
      end

      it 'returns json with assigned values' do
        request
        token = User.last.authentication_token
        expect(response.body).to be_json_eql('test@studytube.nl'.to_json).at_path('email')
        expect(response.body).to be_json_eql(token.to_json).at_path('authentication_token')
      end

      it 'returns json according the schema' do
        request
        expect(response).to match_response_schema('user')
      end
    end

    context 'missing email' do
      let(:params) do
        {registration: {email: '', password: '12345678', password_confirmation: '12345678'}}
      end
      let(:request) {post '/api/registrations', params: params, headers: {}, xhr: true}

      it_behaves_like 'InvalidUser' do
        let(:message) {"Email can't be blank"}
        let(:status) {422}
      end
    end

    context 'missing password' do
      let(:params) do
        {registration: {email: 'test@studytube.nl', password: '', password_confirmation: '12345678'}}
      end
      let(:request) {post '/api/registrations', params: params, headers: {}, xhr: true}

      it_behaves_like 'InvalidUser' do
        let(:message) {"Password can't be blank, Password confirmation doesn't match Password"}
        let(:status) {422}
      end
    end

    context 'wrong password confirmation' do
      let(:params) do
        {registration: {email: 'test@studytube.nl', password: '12345678', password_confirmation: ''}}
      end
      let(:request) {post '/api/registrations', params: params, headers: {}, xhr: true}

      it_behaves_like 'InvalidUser' do
        let(:message) {"Password confirmation doesn't match Password"}
        let(:status) {422}
      end
    end
  end

  describe 'DELETE :destroy' do
    let!(:user) {create(:user)}

    context 'authenticated' do
      let_valid_headers

      let(:request) {delete '/api/registrations', params: {}, headers: headers, xhr: true}

      it 'returns status :ok' do
        request
        expect(response).to be_success
      end

      it 'records a new user into database' do
        expect {request}.to change(User, :count).by(-1)
      end

      it 'returns empty response' do
        request
        expect(response.body).to be_empty
      end
    end

    context 'unauthenticated' do
      context 'wrong email' do
        let_wrong_email_headers

        let(:request) {delete '/api/registrations', params: {}, headers: headers, xhr: true}

        it_behaves_like 'InvalidUser' do
          let(:message) {""}
          let(:status) {401}
        end

      end

      context 'wrong token' do
        let_wrong_token_headers

        let(:request) {delete '/api/registrations', params: {}, headers: headers, xhr: true}

        it_behaves_like 'InvalidUser' do
          let(:message) {""}
          let(:status) {401}
        end
      end
    end
  end
end
