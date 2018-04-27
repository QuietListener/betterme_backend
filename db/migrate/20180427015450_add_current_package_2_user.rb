class AddCurrentPackage2User < ActiveRecord::Migration
  def change
    add_column :users ,:package_id,:integer
  end

end
