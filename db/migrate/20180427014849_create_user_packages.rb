class CreateUserPackages < ActiveRecord::Migration
  def change
    create_table :user_packages do |t|

      t.integer :user_id
      t.integer :package_id
      t.integer :type

      t.timestamps null: false
    end

    add_index :user_packages,[:user_id,:package_id,:type],:unique=>true
  end
end
