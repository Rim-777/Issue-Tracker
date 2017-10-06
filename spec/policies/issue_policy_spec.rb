require 'rails_helper'

RSpec.describe IssuePolicy do

  let(:user) {User.new}

  subject {described_class}

  permissions :create?, :update?, :destroy? do
    it 'denies access for a manager' do
      user.add_role :manager
      expect(subject).not_to permit(user, Issue.new())
    end

    it 'grants access for a regular user' do
      expect(subject).to permit(user, Issue.new())
    end
  end

  permissions :assign? do
    it 'grants access for a manager if an issue is not assigned or assigned to this user' do
      user.add_role :manager
      expect(subject).to permit(user, Issue.new(assignee: nil))
      expect(subject).to permit(user, Issue.new(assignee: user, user: user))
    end

    it 'denies access for a regular user' do
      expect(subject).not_to permit(user, Issue.new())
      expect(subject).not_to permit(user, Issue.new(assignee: nil))
      expect(subject).not_to permit(user, Issue.new(assignee: user, user: user))
    end

    it 'denies access for a manager if issue assigned to another user' do
      user.add_role :manager
      expect(subject).not_to permit(user, Issue.new(assignee: User.new))
    end
  end

  permissions :set_state? do
    it 'grants access for a manager' do
      user.add_role :manager
      expect(subject).to permit(user, Issue.new())
    end

    it 'denies access for a regular user' do
      expect(subject).not_to permit(user, Issue.new())
    end
  end
end
