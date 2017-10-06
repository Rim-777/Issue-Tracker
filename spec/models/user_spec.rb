require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:issues) }
  it { should have_many(:assigned_issues).class_name('Issue').with_foreign_key('assignee_id')}
end
