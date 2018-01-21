class User < ActiveRecord::Base

  def my_status
      r_count = PlanRecord.where("user_id = ?", self.id).count
      if(r_count <= 3)
        return 1
      elsif(r_count >3 and r_count <= 7)
        return 2
      elsif(r_count > 7 and r_count < 21)
        return 3
      end
  end

end
