class User < ApplicationRecord
  acts_as_token_authenticatable
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :issues, dependent: :destroy, inverse_of: :user
  has_many :assigned_issues, class_name: 'Issue', foreign_key: :assignee_id, inverse_of: :user
end
