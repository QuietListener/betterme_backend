class AddStatusToEnsureCode < ActiveRecord::Migration
  def change
    add_column :ensure_codes,:status,:string,default: 0
  end
end
