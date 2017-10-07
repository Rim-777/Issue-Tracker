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

  default_scope {order(created_at: :desc )}

  def trigger_event(name)
    message = "#{name} #{I18n.t('validations.forbidden_event')}"
    raise Tracker::InvalidEventError, message if state_paths.events.exclude?(name.to_sym)
    send(name.to_sym)
  end

  def assign(assignee)
    update(assignee: self.assignee.present? ? nil : assignee)
  end

  def self.fetch_collection_by(**options)
    state = options[:state]
    user = options[:user]
    if state
      user.has_role?(:manager) ? Issue.where(state: state) : Issue.where(state: state, user: user)
    else
      user.has_role?(:manager) ? Issue.all : Issue.where(user: user)
    end
  end

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
