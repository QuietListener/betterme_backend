class CreateUserRewards < ActiveRecord::Migration
  def change
    create_table :user_rewards do |t|

      t.integer :user_id
      t.integer :reward_type
      t.integer :content
      t.integer :state
      t.integer :token

      t.timestamps null: false
    end
  end
end
