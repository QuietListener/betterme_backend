class CreateUserVideos < ActiveRecord::Migration
  def change
    create_table :user_videos do |t|

      t.integer :user_id
      t.integer :video_id
      t.integer  :uvtype

      t.timestamps null: false
    end
    add_index :user_videos,[:user_id,:video_id, :uvtype],:unique => true
  end
end
