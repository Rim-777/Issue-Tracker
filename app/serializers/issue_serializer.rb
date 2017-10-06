class IssueSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :assignee_id, :title, :description, :created_at, :updated_at, :state
end
