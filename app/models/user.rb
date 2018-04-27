#encoding:utf-8
require 'digest/sha1'

class User < ActiveRecord::Base

  PROVIDER_PHONE= 5;
  PROVIDER_WX = 1;
  PROVIDER_QQ = 3;

  DakaTodayError = -1
  DakaTodayAllFinished = 0
  DakaTodayNoneFinished = 1
  DakaTodayPartFinished = 2

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

=begin

{"openid":"oGCPmw5ajMA33vczHJylSmORcWnQ","nickname":"君君","sex":1,"language":"zh_CN","city":"成都","province":"四川","country":"中国","headimgurl":"http:\/\/wx.qlogo.cn\/mmopen\/vi_32\/Q0j4TwGTfTKBicCDZnwQyerMibwxRTygO0OBjDOEib2lElMS0HzYiawXg3mFtdV5vEicYkZFPCotzruHQZhzWzpLfsg\/132","privilege":[]}

=end
  def set_user_from_wx(wx)

    self.provider = PROVIDER_WX
    self.nick_name = wx.nickname
    self.openid = wx.openid
    self.unionid=wx.unionid

    self.avatar=wx.headimgurl
    self.country=wx.country
    self.province=wx.province
    self.city = wx.city

    self.access_token=gen_access_token(wx.openid)
  end


  def gen_access_token(id)
    return id;
  end

  def self.encode_passwd(password)
    return Digest::SHA1.hexdigest(password)
  end

  def plan_status
     now = DateTime.now
     plans = Plan.where("user_id = ? and start < ? and end > ?", self.id, now, now)
     return DakaTodayError if(plans.length == 0)

     statuses = plans.map {|p| p.finished_daka_today() ? 1 : 0 }
     sum = statuses.sum

     cur_plan_count = plans.length;
    if(sum == 0)
      return DakaTodayNoneFinished,cur_plan_count
    elsif(sum < statuses.length)
      return DakaTodayPartFinished,cur_plan_count
    else
      return DakaTodayAllFinished,cur_plan_count
    end
  end

  def reward
    UserReward.where("created_at > ?",DateTime.now.beginning_of_day).last
  end

  def statistics
    reward_score = UserReward.where("user_id = ? and state = ? and reward_type in (#{[UserReward::TypeDayTaskFinishedReward,UserReward::TypeInitReward,UserReward::TypeDakaReward].join(',')})",self.id,UserReward::StateDone).pluck(:content).sum

    used_score = UserReward.where("user_id = ? and state = ? and reward_type = ?",self.id,UserReward::StateDone,UserReward::TypeCreatePlan).pluck(:content).sum

    #当前总积分
    total_score = reward_score - used_score

    #打卡次数
    daka_count = PlanRecord.where("user_id = ? ",self.id).count

    return {total_score:total_score,daka_count:daka_count}
  end

  def package
     return nil  if(self.package_id.blank?)
     Package.where(:id=>self.package_id).first
  end


  def add_package(package_id,type)

    if not [UserPackage::TypeLike,UserPackage::TypeFinished,UserPackage::TypePlayed].include? type
      return;
    end

    up_ = UserPackage.where(:user_id => self.id,:package_id => package_id,:ttype => type).first

    if up_
      puts "#{up_}, 已经存在了"
      return;
    end

    package = Package.find(package_id)

    up = UserPackage.new
    up.user_id=self.id
    up.package_id=package.id
    up.ttype=type
    up.save!


    if(type == UserPackage::TypeLike)
      package.star_count += 1;
      package.save
    elsif(type == UserPackage::TypePlayed)
      package.play_count += 1;
      package.save
    end

    return;
  end


  def remove_package(package_id,type)
    package = Package.find(package_id)
    up = UserPackage.where(:user_id => self.id,:package_id => package.id,:ttype=>type).first
    up.delete if up

    if type == UserPackage::TypeLike
      package.star_count -= 1 if package.star_count>0
      package.save;
    end
  end


end
