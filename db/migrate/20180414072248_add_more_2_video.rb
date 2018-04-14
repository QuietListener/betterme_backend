class AddMore2Video < ActiveRecord::Migration
  def change
    add_column :videos,:poster,:string
    add_column :videos,:video_file_name,:string
    add_column :videos,:srt_file_name,:string

  end
end
