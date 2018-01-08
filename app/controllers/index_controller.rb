class IndexController < ApplicationController

  before_filter :add_cors_headers

  def index
    
  end

  def user
    u = User.first
    respond_to_ok(u,"");
  end

  def create_plan
      name = params[:name].strip
      start_time = params[:start_time]
      end_time = params[:end_time]

      user = User.first

      p = Plan.where("user")
      if(p ！= nil)
        raise Exception("已经有一个重名的plan了")
      end

      p = Plan.new
      p.user_id = user.id
      p.name = name
      p.start = start_time
      p.end = end_time
      p.save;

      respond_to_ok(p,"");
  end


  def plan_records_stat(plan)
      plan_id = plan.id
      finished_days = PlanRecord.where("plan_id = ?",plan_id).count
      total_days = (plan.end - plan.start).to_i/86400
      return total_days,finished_days
  end

  def plan
    id = params[:id]
    plan = Plan.where("id=?",id).first
    respond_to_ok(plan,"")
  end

  def plans
    user_id = params[:user_id]
    plans = Plan.where("user_id=?",user_id).order("updated_at desc");

    plans_ = plans.map{|p|
      p_ = p.as_json;
      p_["finished_daka_today"] = p.finished_daka_today();
      total_days , finished_days = plan_records_stat(p)
      p_["total_days"] = total_days
      p_["finished_days"] = finished_days
      p_
    }

    respond_to_ok(plans_,"")
  end


  def create_plan_record
    plan_id = params[:plan_id]
    plan = Plan.where(:id => plan_id).first
    pr = PlanRecord.new
    pr.user_id=plan.user_id
    pr.plan_id = plan.id
    pr.desc = params[:desc].strip
    pr.save

    prs = PlanRecord.where("plan_id = ?",plan.id)
    respond_to_ok(prs,"")
  end

  def plan_records
    plan_id = params[:plan_id]
    plan = Plan.where(:id => plan_id).first
    prs = PlanRecord.where("plan_id = ?",plan.id).order("created_at desc");

    respond_to_ok(prs,"")
  end

end
