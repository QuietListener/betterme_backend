class User < ActiveRecord::Base

  PROVIDER_WX = 1;
  PROVIDER_QQ = 3;

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
end
