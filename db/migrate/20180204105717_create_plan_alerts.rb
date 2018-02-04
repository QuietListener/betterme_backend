class CreatePlanAlerts < ActiveRecord::Migration
  def change
    create_table :plan_alerts do |t|

      t.integer :user_id
      t.integer :plan_id

      t.integer :hours
      t.integer :minutes

      t.timestamps null: false
    end
  end
end
