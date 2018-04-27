class UserVideo < ActiveRecord::Base

  TypeLike = 1  #搜藏的
  TypeWatched = 2 #观看过的

  def video
    return nil if not self.video_id
    return Video.where(:id=>self.video_id).first
  end

end
