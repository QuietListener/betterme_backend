class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|

      t.string  :name
      t.datetime :start
      t.datetime :end
      t.string  :desc

      t.timestamps null: false
    end
  end
end
