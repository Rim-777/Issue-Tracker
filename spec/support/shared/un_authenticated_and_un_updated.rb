shared_examples_for 'UnAuthenticatedAndUnUpdated' do

  context 'wrong authentication_token' do
    let_wrong_token_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change an issues attributes" do
      request
      expect(issue.title).to eq 'The old Issue Title'
      expect(issue.description).to eq 'The old Issue Description'
    end
  end

  context 'wrong email' do
    let_wrong_email_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change an issues attributes" do
      request
      expect(issue.title).to eq 'The old Issue Title'
      expect(issue.description).to eq 'The old Issue Description'
    end
  end
end