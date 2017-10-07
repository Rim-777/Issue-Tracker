shared_examples_for 'UnAuthenticated' do

  context 'wrong authentication_token' do
    let_wrong_token_headers

    it_behaves_like 'UnAuthenticatedUser'
  end

  context 'wrong email' do
    let_wrong_email_headers

    it_behaves_like 'UnAuthenticatedUser'
  end
end