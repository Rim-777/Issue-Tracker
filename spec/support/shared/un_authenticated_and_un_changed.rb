shared_examples_for 'UnAuthenticatedAndUnChanged' do

  context 'wrong authentication_token' do
    let_wrong_token_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change an issues count" do
      expect {request}.to_not change(Issue, :count)
    end
  end

  context 'wrong email' do
    let_wrong_email_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change an issues count" do
      expect {request}.to_not change(Issue, :count)
    end
  end
end