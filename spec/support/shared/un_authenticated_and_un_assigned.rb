shared_examples_for 'UnAuthenticatedAndUnAssigned' do

  let!(:issue) {create(:issue, user: user)}
  context 'wrong authentication_token' do
    let_wrong_token_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't assign manager to issue" do
      request
      expect(issue.assignee).to be nil
    end
  end

  context 'wrong email' do

  end
end