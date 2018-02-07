#encoding:utf-8
#配置任务
require 'digest/sha1'
require "#{Rails.root.to_s}/lib/weixin_api.rb"

class WeixinController < ApplicationController
  #protect_from_forgery
  # skip_before_filter :login_filter,:only => [:login,:logout,:index,:register]
  # before_filter :login_filter,only: [:user_info]

  #https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc8c2179b9a8c63ef&redirect_uri=http%3A%2F%2F4e3ab72f.ngrok.io%2Fweixin%2Fwein_login_call_back_snsapi_base&response_type=code&scope=snsapi_userinfo&state=STATE#wechat_redirect
  #注意 scope=snsapi_userinfo 才行, 使用 snsapi_base会在 str_user_info = RestClient.get(str_user_info_url)出错
  def wein_login_call_back_snsapi_base
      code = params[:code]

      if params[:code].blank?
        render :text => 'code is blank'
      else

        #通过code去获取access_token
        str_url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{$appid}&secret=#{$app_secret}&code=#{params[:code]}&grant_type=authorization_code&"
        res = RestClient.get(str_url)
        token_data = JSON.parse(res)

        Rails.logger.info(token_data)
        if token_data["errcode"].blank?

          #通过access_token获取user_info
          Rails.logger.info "access_token值为:"+token_data["access_token"]
          str_user_info_url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{token_data["access_token"]}&openid=#{token_data["openid"]}&lang=zh_CN"
          Rails.logger.info str_user_info_url
          str_user_info = RestClient.get(str_user_info_url)
          Rails.logger.info str_user_info.to_s
          #render json:  str_user_info
          @user_info = JSON.parse(str_user_info)
          session[:user] = @user_info

          Rails.logger.info (@user_info)
          user_info =  OpenStruct.new (@user_info)
          openid = user_info.openid
          u = User.where(:openid => openid).first
          if u.blank?
            u = User.new
            u.set_user_from_wx(user_info)
            u.save!
          end

          if u.id > 0 and u.access_token
            cookies[:access_token] = {
                :value => u.access_token,
                :expires => 1.year.from_now,
                :domain => '4e3ab72f.ngrok.io'
            }
          end

          redirect_to "/home"
        else
          Rails.logger.info token_data.to_s
          render json: token_data
        end
      end

  end



  def get_share_config
    url = "http://4e3ab72f.ngrok.io/home"
    config = WeixinApi.get_weixin_share_config(WeixinApi::JUDU_WEIXIN_APP,url)
    ret = {
        config:config,
        url:url,
        desc:"测试一下"
    }

    render json: ret
  end

end



#{"openid":"oGCPmw5ajMA33vczHJylSmORcWnQ","nickname":"君君","sex":1,"language":"zh_CN","city":"成都","province":"四川","country":"中国","headimgurl":"http:\/\/wx.qlogo.cn\/mmopen\/vi_32\/Q0j4TwGTfTKBicCDZnwQyerMibwxRTygO0OBjDOEib2lElMS0HzYiawXg3mFtdV5vEicYkZFPCotzruHQZhzWzpLfsg\/132","privilege":[]}

