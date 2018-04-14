class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :title_cn
      t.string :author
      t.string :author_cn
      t.string :desc
      t.string :desc_cn

      t.string :video_url
      t.string :srt_url

      t.timestamps null: false
    end
  end
end
