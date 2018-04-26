class Package < ActiveRecord::Base

  def videos
    video_ids = PackageVideo.where(:package_id => self.id).pluck(:video_id)
    return Video.where(:id=>video_ids)
  end


  def add_video(video_id)
    pvs =  PackageVideo.where(:package_id => self.id,:video_id => video_id)
    if pvs.size == 0

        v = Video.find(video_id)
        if not v
          puts "video (id = #{video_id} ) 不存在"
          return;
        end

        pv = PackageVideo.new
        pv.package_id=self.id
        pv.video_id = v.id
        pv.save!
    else
      puts "video (id = #{video_id} ) 已经在package中了"
    end
  end


  def remove_video(video_id)
    PackageVideo.where(:package_id => self.id,:video_id => video_id).first.delete
  end


end
