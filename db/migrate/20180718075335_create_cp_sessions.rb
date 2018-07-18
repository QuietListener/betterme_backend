class CreateCpSessions < ActiveRecord::Migration
  def change
    create_table :cp_sessions do |t|

      t.string :words_ids
      t.string :choices_words_ids

      t.integer :user1_id
      t.integer :user2_id

      t.string :user1_choices
      t.string :user2_choices

      t.string :user1_used_time
      t.string :user2_used_time

      t.integer :user1_idx
      t.integer :user2_idx

      t.timestamps null: false

    end
  end
end
