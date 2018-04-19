class CreateUtypes < ActiveRecord::Migration

  def change
    create_table :utypes do |t|
      t.string :name
      t.integer :status
      t.timestamps null: false
    end
  end

end
