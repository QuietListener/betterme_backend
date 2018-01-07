class CreatePlanRecords < ActiveRecord::Migration
  def change
    create_table :plan_records do |t|

      t.integer :user_id
      t.integer :plan_id

      t.string  :desc
      t.string  :images

      t.timestamps null: false
    end
  end
end
