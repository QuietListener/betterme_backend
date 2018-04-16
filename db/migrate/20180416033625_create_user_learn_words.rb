class CreateUserLearnWords < ActiveRecord::Migration
  def change
    create_table :user_learn_words do |t|

      t.integer  :user_id ,:null=>false
      t.integer  :learn_word_id,:null=>false
      t.integer  :status ,:default=>0

      t.timestamps null: false
    end

    add_index :user_learn_words, [:user_id,:learn_word_id], unique: true
  end
end
