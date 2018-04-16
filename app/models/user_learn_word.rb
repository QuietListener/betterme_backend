class UserLearnWord < ActiveRecord::Base
  StateDeleted = 1
  StateOk = 0

  def learn_word
    LearnWord.where(:id =>self.learn_word_id).first
  end

end
