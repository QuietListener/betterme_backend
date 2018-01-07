class AddUserId2Plan < ActiveRecord::Migration
  def change
    add_column :plans,:user_id,:integer,:null=>false
  end
end
