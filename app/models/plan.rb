class Plan < ActiveRecord::Base

  def finished_daka_today
     pr = PlanRecord.where("plan_id = ?",self.id).order("created_at desc").first

     return false if not pr;

     ct = pr.created_at;
     str1 = ct.strftime("%Y-%m-%d");
     str2 =  DateTime.now.strftime("%Y-%m-%d")
     return str1 == str2;
  end


  def total_days
    return (self.end.to_date-self.start.to_date).to_i+1
  end
end
