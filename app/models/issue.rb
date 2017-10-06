class Issue < ApplicationRecord
  validates :title, :description, :state, presence: true
  validates :assignee_id, presence: true, if: lambda { in_progress? || resolved? }
  validates :title, uniqueness: true
  belongs_to :user, inverse_of: :issues
  belongs_to :assignee,
             class_name: 'User',
             foreign_key: :assignee_id,
             inverse_of: :assigned_issues,
             optional: true

  def trigger_event(name)
    raise NameError, name, I18n.t('validations.forbidden_event') if state_paths.events.exclude?(name.to_sym)
    send(name.to_sym)
  end

  def assign(assignee)
    update(assignee: self.assignee.present? ? nil : assignee)
  end

  private

  state_machine :initial => :pending do
    event :open_issue do
      transition all => :in_progress
    end

    event :close_issue do
      transition all => :resolved
    end

    event :stop_issue do
      transition all => :pending
    end
  end
end
