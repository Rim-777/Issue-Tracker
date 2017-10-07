require 'rails_helper'

RSpec.describe Issue, type: :model do
  it {should validate_presence_of(:title)}
  it {should validate_presence_of(:description)}
  it {should validate_presence_of(:state)}
  it {should validate_uniqueness_of(:title)}
  it {should belong_to(:user)}
  it {should belong_to(:assignee).class_name('User').with_foreign_key('assignee_id')}


  context 'if in_progress?' do
    before {allow(subject).to receive(:in_progress?).and_return(true)}
    it {should validate_presence_of(:assignee_id)}
  end

  context 'if resolved?' do
    before {allow(subject).to receive(:resolved?).and_return(true)}
    it {should validate_presence_of(:assignee_id)}
  end

  let!(:user) {create(:user)}

  describe '#assign' do
    context 'the issue is not assigned' do
      let!(:issue) {create(:issue, user: user)}

      it 'returns true' do
        expect(issue.assign(user)).to eq true
      end

      it 'assigns the user to the issue as assignee' do
        issue.assign(user)
        expect(issue.assignee).to eq user
      end

      it 'changes an issues count fo the user' do
        expect {issue.assign(user)}.to change(user.assigned_issues, :count).by(1)
      end
    end

    context 'the issue is assigned' do
      let!(:issue) {create(:issue, user: user, assignee: user)}

      it 'returns true' do
        expect(issue.assign(user)).to eq true
      end

      it 'unassigns the assignee from the issue' do
        issue.assign(user)
        expect(issue.assignee).to be_nil
      end

      it 'changes an issues count fo the user' do
        expect {issue.assign(user)}.to change(user.assigned_issues, :count).by(-1)
      end
    end
  end

  describe '#trigger_event' do
    let!(:pending_issue) {create(:issue, user: user, assignee: create(:user))}
    let!(:resolved_issue) {create(:issue, user: user, assignee: create(:user), state: 'resolved')}
    let!(:progressing_issue) {create(:issue, user: user, assignee: create(:user))}


    context 'in_progress' do
      it 'sets state in_progress' do
        [pending_issue, resolved_issue].each do |issue|
          issue.trigger_event('open_issue')
          expect(issue.in_progress?).to eq true
        end
      end
    end

    context 'resolved' do
      it 'sets state resolved' do
        [pending_issue, progressing_issue].each do |issue|
          issue.trigger_event('close_issue')
          expect(issue.resolved?).to eq true
        end
      end
    end

    context 'pending' do
      it 'sets state pending' do
        [resolved_issue, progressing_issue].each do |issue|
          issue.trigger_event('stop_issue')
          expect(issue.pending?).to eq true
        end
      end
    end

    context 'unknown event name' do
      let(:message) {'HackIssue - Event is invalid'}
      it 'raise error' do
        expect {pending_issue.trigger_event('HackIssue')}.to raise_error(Tracker::InvalidEventError, message)
      end
    end
  end

  describe '.fetch_collection_by' do
    let(:manager) {create(:user)}

    let!(:user_pending_issues) do
      create_list(:issue, 2, user: user, state: 'pending')
    end

    let!(:user_progress_issues) do
      create_list(:issue, 2, user: user, state: 'in_progress', assignee: user)
    end

    let!(:manager_pending_issues) {create_list(:issue, 2, user: manager, state: 'pending')}

    let!(:manager_progress_issues) do
      create_list(:issue, 2, user: manager, state: 'in_progress', assignee: manager)
    end

    let(:user_issues) do
      (user_pending_issues + user_progress_issues).sort_by(&:created_at).reverse
    end

    let(:all_issues) do
      (user_issues  + manager_pending_issues + manager_progress_issues).sort_by(&:created_at).reverse
    end

    let(:all_pending)do
      (user_pending_issues + manager_pending_issues).sort_by(&:created_at).reverse
    end

    let(:all_progressing) do
      (user_progress_issues + manager_progress_issues).sort_by(&:created_at).reverse
    end

    context 'regular user' do
      it 'returns all issues of the regular user' do
        expect(Issue.fetch_collection_by(user: user)).to eq user_issues
      end

      it 'returns issues of the regular user filtered by a passed state' do
        pending_issues = user_pending_issues.sort_by(&:created_at).reverse
        progress_issues = user_progress_issues.sort_by(&:created_at).reverse
        expect(Issue.fetch_collection_by(state: 'pending', user: user)).to eq pending_issues
        expect(Issue.fetch_collection_by(state: 'in_progress', user: user)).to eq progress_issues
      end
    end

    context 'manager' do
      before {manager.add_role :manager}

      it 'returns all issues' do
        expect(Issue.fetch_collection_by(user: manager)).to eq all_issues
      end

      it 'returns all issues filtered by  a passed state' do
        expect(Issue.fetch_collection_by(state: 'pending', user: manager)).to eq all_pending
        expect(Issue.fetch_collection_by(state: 'in_progress', user: manager)).to eq all_progressing
      end
    end
  end
end
