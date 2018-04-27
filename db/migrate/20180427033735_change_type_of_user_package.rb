class ChangeTypeOfUserPackage < ActiveRecord::Migration
  def change
    rename_column :user_packages,:type,:ttype
  end
end
