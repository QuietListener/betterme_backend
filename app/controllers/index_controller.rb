class IndexController < ApplicationController

  before_filter :add_cors_headers

  def index
    logger.info request.inspect
  end

  def login

  end


  def home

  end

  def register
    username = params[:username]
    password = parasm[:password]

    if(username.blank? || password.blank? )
      raise Exception.new("用户名或者密码为空")
    end

    uc=User.where(:name=>username).count

    if(uc > 0)
      raise Exception.new("用户名已经存在了")
    end


  end

  def test1
    logger.info request.inspect
  end

  def user
    u = User.first
    respond_to_ok(u,"");
  end

  def create_plan

      id = params[:id]
      name = params[:name].strip
      start_time = params[:start_time]
      end_time = params[:end_time]

      user = User.first

      p = Plan.where("name=? and user_id = ?",name,user.id);
      if(p ！= nil)
        raise Exception("已经有一个重名的plan了")
      end


      p = Plan.new
      if not id.blank?
        p = Plan.find(id);
        if p.blank?
          raise Exception.new("没有id为#{id}的计划")
        end
      end




      p.user_id = user.id
      p.name = name
      p.start = start_time
      p.end = end_time
      p.save;

      respond_to_ok(p,"");
  end


  def create_or_update_alert_(user_id,plan_id,hours,minutes)
    pa = PlanAlert.where("user_id = ? and plan_id = ?",user_id,plan_id).first;

    if pa.blank?
      pa = PlanAlert.new
    end

    pa.plan_id = plan_id
    pa.user_id= user_id
    pa.hours= hours
    pa.minutes=minutes

    pa.save

    return pa
  end

  def create_or_update_alert
    plan_id = params[:plan_id]
    user = User.first

    hours = params[:hours].strip
    minutes = params[:minutes].strip
    pa = create_or_update_alert_(user.id,plan_id,hours,minutes)
    respond_to_ok(pa,"");

  end


  def plan_records_stat(plan)
      plan_id = plan.id
      finished_days = PlanRecord.where("plan_id = ?",plan_id)
      finished_days_count = PlanRecord.where("plan_id = ?",plan_id).count
      total_days_count = (plan.end - plan.start).to_i/86400

      return total_days_count,finished_days_count,finished_days
  end

  def plan_decorate(p)
    p_ = p.as_json;

    p_["finished_daka_today"] = p.finished_daka_today();
    total_days_count , finished_days_count, finished_days = plan_records_stat(p)
    p_["total_days_count"] = total_days_count
    p_["finished_days_count"] = finished_days_count
    p_["finished_days"] = finished_days

    return p_
  end

  def plan
    id = params[:id]
    plan = Plan.where("id=?",id).first
    plan_ = plan_decorate(plan)
    respond_to_ok(plan_,"")
  end

  def plans
    user_id = params[:user_id]
    plans = Plan.where("user_id=?",user_id).order("updated_at desc");
    plans_ = plans.map{|p|   plan_decorate(p)  }
    respond_to_ok(plans_,"")
  end

  def create_plan_record

    plan_id = params[:plan_id]
    plan = Plan.where(:id => plan_id).first
    pr = PlanRecord.new

    time_now = Time.now

    # if(time_now > plan.end)
    #   raise Exception.new("这个小目标已经过期了喔")
    # end
    #
    # if(time_now < plan.start)
    #   raise Exception.new("还没有开始呢~")
    # end


    pr.user_id=plan.user_id
    pr.plan_id = plan.id
    pr.desc = params[:desc].strip
    pr.images = JSON.dump(params[:images]);
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

