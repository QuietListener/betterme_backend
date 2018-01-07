class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nick_name
      t.string :avatar
      t.integer :gender
      t.string  :access_token

      t.timestamps null: false
    end
  end
end
