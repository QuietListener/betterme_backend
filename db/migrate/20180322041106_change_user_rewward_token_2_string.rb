class ChangeUserRewwardToken2String < ActiveRecord::Migration
  def change
    change_column :user_rewards,:token,:string,:null => false
  end
end
