class AddNamePasswordToUser < ActiveRecord::Migration
  def change
    add_column :users,:name,:string
    add_column :users,:password,:string
  end
end
