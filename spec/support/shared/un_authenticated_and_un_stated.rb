shared_examples_for 'UnAuthenticatedAndUnStated' do
  let(:params) {{state_event: 'open_issue'}}
  let(:request) {patch "/api/issues/#{issue.id}/set_state", params: params, headers: headers, xhr: true}
  context 'wrong authentication_token' do
    let_wrong_token_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change the state of the issue" do
      request
      issue.reload
      expect(issue.pending?).to be true
    end
  end

  context 'wrong email' do
    let_wrong_email_headers

    it_behaves_like 'UnAuthenticatedUser'

    it "doesn't change the state of the issue" do
      request
      issue.reload
      expect(issue.pending?).to be true
    end
  end
end