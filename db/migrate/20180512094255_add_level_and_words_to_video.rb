class AddLevelAndWordsToVideo < ActiveRecord::Migration
  def change
    add_column :videos,:level,:integer,:default => 0
    add_column :videos,:words_count,:integer,:default => 0
  end
end
