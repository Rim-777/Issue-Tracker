class User < ApplicationRecord
  acts_as_token_authenticatable
  rolify

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :issues, dependent: :destroy, inverse_of: :user
  has_many :assigned_issues,
           class_name: 'Issue',
           foreign_key: :assignee_id,
           inverse_of: :user
end
