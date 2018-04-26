class CreatePackageVideos < ActiveRecord::Migration
  def change
    create_table :package_videos do |t|
      t.integer :package_id
      t.integer :video_id
      t.timestamps null: false
    end
  end
end
