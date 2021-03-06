#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'

UsedScorePerDay = 50;
InitScore = 2100;

class IndexController < ApplicationController

  before_filter :add_cors_headers,:get_user,:except => [:search_word,:index,:login,:register,:ensure_code,:test1]

  def test

  end

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

  def ensure_code
    username = params[:username]
    if(username.blank? )
      raise Exception.new("手机号为空")
    end

    if not username=~/^1\d+$/ or username.size < 11
      raise Exception.new("手机号码是不是输错了~")
    end

    uc = User.where(:name => username.strip).count
    if(uc > 0)
      raise Exception.new("用户已经存在")
    end

    ec = EnsureCode.where(:phone => username).order("created_at desc").limit(1).first

    if not ec.blank?
      updated_at = ec.updated_at
      now = Time.now
      span = now - updated_at

      if(span < 60)
        raise Exception.new("发送得太频繁");
      end
   end

    ec = EnsureCode.new
    ec.phone=username
    ec.code = rand(9999)
    ec.save!

    if(ec.id>0)
      ret =  BUtils.send_ems(ec.code);
      respond_to_ok("发送成功","发送成功");
    end


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

    User.transaction do

      #新用户
      u = User.new
      u.name = username
      u.password = User.encode_passwd(password)
      u.access_token= "#{u.password}#{rand(1000)}";
      u.provider= User::PROVIDER_PHONE;
      u.save!;

      #新用户奖励的score
      ur = UserReward.new
      ur.user_id = u.id
      ur.reward_type=UserReward::TypeInitReward
      ur.content = InitScore
      ur.token = u.id
      ur.state = UserReward::StateDone
      ur.save!
   end

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

    user = @user.as_json(:include=>[:package])
    r = @user.reward

    if r and r.token and r.state == UserReward::StateInit
        user["lucky_token"] = r.token
    else
      user["lucky_token"] = nil;
    end

    respond_to_ok(user,"");
  end

  def create_plan

      id = params[:id]
      name = params[:name].strip
      start_time = params[:start_time]
      end_time = params[:end_time]
      days = params[:days]

      user = @user

      p = Plan.where("name=? and user_id = ?",name,user.id);
      if(p ！= nil)
        raise Exception("已经有一个重名的计划了")
      end


      p = Plan.new
      if not id.blank? and id.to_i >= 0 #更新plan
        p = Plan.where(:id=>id).first;
        if p.blank?
          raise Exception.new("没有id为#{id}的计划")
        end
      end

      end_time_ = Date.parse(end_time)
      start_time_ = Date.parse(start_time)
      p.user_id = user.id
      p.name = name

      if p.id.blank?
        p.start = start_time_
        p.end = end_time_
      end

      day_span = p.total_days #天数
      if(day_span<=0)
        raise Exception.new("计划结束时间应该比开始时间晚~");
      end

      #需要的分数
      used_scores = day_span * UsedScorePerDay
      statistics = @user.statistics
      total_score = statistics[:total_score];

      if p.id.blank?
        ur = UserReward.new
        if used_scores > total_score
          raise Exception.new("创建计划需要#{used_scores}(#{used_scores}=#{day_span} x #{UsedScorePerDay})分，但是你的账户只有#{total_score}分")
        end

        if ur
          ur.user_id=@user.id
          ur.content= used_scores
          ur.reward_type=UserReward::TypeCreatePlan
          ur.state = UserReward::StateDone
        end

      end



      @user.transaction do
        p.save!;
        if ur
          ur.token = p.id
          ur.save!
        end

        hours = params[:hours]
        minutes = params[:minutes]

        if p.id
          pa = create_or_update_alert_(@user.id,p.id,hours,minutes)
        end

      end

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
      total_days_count = plan.total_days

      return total_days_count,finished_days_count,finished_days
  end

  def plan_decorate(p)
    p_ = p.as_json;

    p_["finished_daka_today"] = p.finished_daka_today();
    total_days_count , finished_days_count, finished_days = plan_records_stat(p)
    p_["total_days_count"] = total_days_count
    p_["finished_days_count"] = finished_days_count
    p_["finished_days"] = finished_days


    pa = PlanAlert.where("user_id = ? and plan_id = ?",@user.id, p.id).first
    p_["alert"]=pa.as_json;

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

    ur1 = UserReward.new
    ur1.reward_type=UserReward::TypeDakaReward
    ur1.user_id=@user.id
    ur1.state = UserReward::StateDone
    ur1.content = rand(20)+50
    ur1.token = pr.id

    ur1.save!


    prs = PlanRecord.where("plan_id = ?",plan.id)
    status,plan_count = @user.plan_status

    if(status == User::DakaTodayAllFinished)

        ur = UserReward.where("user_id=? and reward_type = ? ",@user.id, UserReward::TypeDayTaskFinishedReward).last;
        if(not ur or  ur.created_at < DateTime.now.beginning_of_day)

            ur = UserReward.new
            ur.user_id = @user.id
            ur.reward_type=0
            ur.token=BUtils.token()
            ur.state= UserReward::StateInit
            ur.content=rand(20) + 10 * plan_count
            ur.save!

        end
    end

    respond_to_ok({prs:prs,reward:ur1},"")
  end

  def plan_records
    plan_id = params[:plan_id]
    plan = Plan.where(:id => plan_id).first
    prs = PlanRecord.where("plan_id = ?",plan.id).order("created_at desc");

    respond_to_ok(prs,"")
  end


  def get_reward
    token = params[:lucky_token]
    ur = UserReward.where("user_id = ? and token = ? and state = ?",@user.id, token,UserReward::StateInit).last

    msg = "ok"
    if  not ur
      msg = "没有可以领取的红包"
    else
      ur.state = UserReward::StateDone
      ur.save!
    end

    respond_to_ok(ur,msg);
  end


  def search_word
    word = params[:word]

    respond_to_ok({
        word: { word:"custom",
                accent:"['kʌstəm]",
                mean_cn:"n. 习惯，惯例；风俗；海关，关税；经常光顾；[总称]（经常性的）顾客; adj. （衣服等）定做的，定制的"
            },
        recomend:[]},"ok")
  end

end

