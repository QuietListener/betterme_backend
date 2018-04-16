class UserLearnWord < ActiveRecord::Base
  StateDeleted = 1
  StateOk = 0

  def learn_word
    LearnWord.where(:id =>self.learn_word_id).first
  end

  def video
    video = Video.new
    if self.video_id
      video = Video.where(:id=>self.video_id).first
    end

    return video
  end

end
