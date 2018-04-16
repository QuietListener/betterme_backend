class AddMovieIdSubtitleToUserLearnWord < ActiveRecord::Migration
  def change

    add_column :user_learn_words,:video_id,:integer
    add_column :user_learn_words, :subtitle,:string

  end
end
