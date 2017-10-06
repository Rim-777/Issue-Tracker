require 'rails_helper'

describe 'Issues API' do
  let!(:user) {create(:user, email: 'test@timo_moss.com', password: '12345678', password_confirmation: '12345678')}
  describe 'POST :create' do
    context 'valid params' do
      let(:params) {{email: user.email, password: '12345678'}}
      let(:request) {post '/api/sessions', params: params, headers: {}, xhr: true}

      it 'returns status :ok' do
        request
        expect(response).to be_success
      end

      it 'returns json with correct values' do
        request
        expect(response.body).to be_json_eql(user.email.to_json).at_path('email')
        expect(response.body).to be_json_eql(user.authentication_token.to_json).at_path('authentication_token')
      end

      it 'returns json according the schema' do
        request
        expect(response).to match_response_schema('user')
      end
    end

    context 'invalid params' do
      context 'wrong email' do
        let(:params) {{email: 'wrong@email.com', password: '12345678'}}
        let(:request) {post '/api/sessions', params: params, headers: {}, xhr: true}
        it_behaves_like 'UnAuthenticatedUser'
      end

      context 'invalid params' do
        context 'wrong email' do
          let(:params) {{email: user.email, password: 'wrong-password'}}
          let(:request) {post '/api/sessions', params: params, headers: {}, xhr: true}
          it_behaves_like 'UnAuthenticatedUser'
        end
      end
    end
  end

  describe 'DELETE :destroy' do
    context 'authenticated' do
      let(:token) {user.authentication_token}
      let(:headers) do
        {
            'X-User-Token' => token,
            'X-User-Email' => user.email,
            "HTTP_ACCEPT" => "application/json"
        }
      end

      let(:request) {delete '/api/sessions', params: {}, headers: headers, xhr: true}

      it 'returns status :ok' do
        request
        expect(response).to be_success
      end

      it 'change authentication_token for user' do
        request
        user.reload
        expect(user.authentication_token).to_not eq token
      end
    end
  end
end
