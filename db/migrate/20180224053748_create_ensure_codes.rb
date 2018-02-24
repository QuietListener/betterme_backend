class CreateEnsureCodes < ActiveRecord::Migration
  def change
    create_table :ensure_codes do |t|

      t.string :phone
      t.string :code

      t.timestamps null: false
    end
  end
end
