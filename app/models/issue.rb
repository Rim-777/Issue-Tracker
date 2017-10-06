class Issue < ApplicationRecord
  validates :title, :description, :state, presence: true
  validates :title, uniqueness: true
  belongs_to :user, inverse_of: :issues
  belongs_to :assignee,
             class_name: 'User',
             foreign_key: :assignee_id,
             inverse_of: :assigned_issues,
             optional: true
end
