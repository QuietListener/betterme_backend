class AddTypeToVideos < ActiveRecord::Migration
  def change
    add_column :videos,:utype_id,:integer
  end
end
