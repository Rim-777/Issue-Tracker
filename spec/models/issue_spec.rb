require 'rails_helper'

RSpec.describe Issue, type: :model do
  let!(:user) {create(:user)}

  describe '#assign' do
    context 'the issue is not assigned' do
      let!(:issue) {create(:issue, user: user)}

      it 'returns true' do
        expect(issue.assign(user)).to eq true
      end

      it 'assigns the user to the issue' do
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

      it 'unassigns the user erom the issue' do
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

    context 'unknown ivent name' do
      it 'raise error' do
        expect {pending_issue.trigger_event('hack')}.to raise_error(NameError, 'hack')
      end
    end
  end
end

