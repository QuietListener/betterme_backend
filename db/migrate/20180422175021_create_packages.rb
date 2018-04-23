class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :title
      t.string :title_cn
      t.string :desc
      t.string :poster
      t.integer :share_count, :default=>0
      t.integer :play_count, :default=>0
      t.integer :star_count,  :default=>0

      t.timestamps null: false
    end

    add_column :videos,  :share_count, :integer, :default=>0
    add_column :videos,  :play_count, :integer, :default=>0
    add_column :videos,  :star_count, :integer, :default=>0

  end
end
