#encoding:utf-8
#配置任务
require 'digest/sha1'

class WeixinController < ApplicationController
  #protect_from_forgery
  # skip_before_filter :login_filter,:only => [:login,:logout,:index,:register]
  # before_filter :login_filter,only: [:user_info]

  #https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc8c2179b9a8c63ef&redirect_uri=http%3A%2F%2Fd64191cd.ngrok.io%2Fweixin%2Fwein_login_call_back_snsapi_base&response_type=code&scope=snsapi_userinfo&state=STATE#wechat_redirect
  #注意 scope=snsapi_userinfo 才行, 使用 snsapi_base会在 str_user_info = RestClient.get(str_user_info_url)出错
  def wein_login_call_back_snsapi_base
      code = params[:code]

      if params[:code].blank?
        render :text => 'code is blank'
      else

        #通过code去获取access_token
        str_url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{$appid}&secret=#{$app_secret}&code=#{params[:code]}&grant_type=authorization_code"
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

          redirect_to "http://a7382992.ngrok.io/chengyu/index.html#/cyhome"
        else
          Rails.logger.info token_data.to_s
          render json: token_data
        end
      end

  end

end
