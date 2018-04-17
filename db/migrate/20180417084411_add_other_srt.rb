class AddOtherSrt < ActiveRecord::Migration
  def change
    add_column :videos,:other_srt_url,:string
    add_column :videos,:other_srt_file_name,:string
  end
end
