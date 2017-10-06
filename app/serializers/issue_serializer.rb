class IssueSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :description, :created_at, :updated_at, :state
  attribute :assignee_id, if: :assignee_exist?

  def assignee_exist?
    !! object.assignee_id
  end
end
