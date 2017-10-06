class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.integer :user_id, index: true, foreign_key: true
      t.integer :assignee_id, index: true, foreign_key: true
      t.string :state, index: true, default: 'pending'
      t.string :title, index: true
      t.text :description
      t.index([:user_id, :state])
      t.index([:assignee_id, :state])
      t.index([:user_id, :title])
      t.index([:assignee_id, :title])
      t.index([:user_id, :title, :state])
      t.index([:assignee_id, :title, :state])

      t.timestamps
    end
  end
end
