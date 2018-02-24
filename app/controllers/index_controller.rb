#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")

class IndexController < ApplicationController

  before_filter :add_cors_headers,:get_user,:except => [:index,:login,:register]

  def index
    logger.info request.inspect
  end

  def login

    username = params[:username]
    password = params[:password]

    if(username.blank? || password.blank? )
      raise Exception.new("用户名或者密码为空")
    end

    encoded_password = User.encode_passwd(password)

    u=User.where(:name=>username,:password=>encoded_password).first

    if(u.blank?)
      raise Exception.new("没有这个用户")
    end

    u.password = nil;
    cookies[:access_token] = {
        :value => u.access_token,
        :expires => 1.year.from_now,
        :domain => BUtils.domain
    }

    respond_to do |format|
      format.json {render :json=>{status:OK,smsg:"ok",data:u}}
      format.html {

        redirect_to "/home"
      }
    end
  end


  def home

  end


  def register
    username = params[:username]
    password = params[:password]
    code = params[:code]

    if(username.blank? || password.blank? )
      raise Exception.new("用户名或者密码为空")
    end

    ec = EnsureCode.where(:phone => username).order("created_at desc").limit(1).first

    if ec.blank?
      raise Exception.new("验证码有问题，请重试")
    end

    if(ec.code != code)
      raise Exception.new("验证码过期，请重试")
    end

    uc=User.where(:name=>username).count

    if(uc > 0)
      raise Exception.new("用户名已经存在了")
    end

    u = User.new
    u.name = username
    u.password = User.encode_passwd(password)
    u.access_token= "#{u.password}#{rand(1000)}";
    u.provider= User::PROVIDER_PHONE;
    u.save!;

    u.password = nil;

    respond_to do |format|
      format.json {render :json=>{status:OK,smsg:"ok",data:u}}
      format.html {

        cookies[:access_token] = {
            :value => u.access_token,
            :expires => 1.year.from_now,
            :domain => BUtils.domain
        }

        redirect_to "/home"
      }
    end
  end

  def test1
    logger.info request.inspect
  end

  def user
    respond_to_ok(@user,"");
  end

  def create_plan

      id = params[:id]
      name = params[:name].strip
      start_time = params[:start_time]
      end_time = params[:end_time]

      user = @user

      p = Plan.where("name=? and user_id = ?",name,user.id);
      if(p ！= nil)
        raise Exception("已经有一个重名的plan了")
      end


      p = Plan.new
      if not id.blank? and id.to_i >= 0
        p = Plan.where(:id=>id).first;
        if p.blank?
          raise Exception.new("没有id为#{id}的计划")
        end
      end

      end_time_ = DateTime.parse(end_time).at_end_of_day
      start_time_ = DateTime.parse(start_time).at_beginning_of_day
      p.user_id = user.id
      p.name = name
      p.start = start_time_
      p.end = end_time_
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
    user = @user

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
    user_id = @user.id
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

