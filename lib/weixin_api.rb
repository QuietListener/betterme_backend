require 'oj'

class WeixinApi

  #BCZ_WEIXIN_APP = {'appid' => 'wxcfbbac84baa7a51b', 'appsecret' => '54424b2aa76f9a0f33ff304d6ca487fa'}
  #PAP_WEIXIN_APP = {'appid' => 'wxa046348e92d916f5', 'appsecret' => '28e9645a4f2f3c0ba47f37dfe7ff306a'}
  JUDU_WEIXIN_APP = {'appid' => $appid, 'appsecret' =>$app_secret}

  
  def self.get_api_token(appid, appsecret)
    token_info = {}
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{appsecret}"

    begin
      token_info = Oj.load(open(url).read)
      raise Exception.new("get access_token failed. token_info => #{token_info}") if token_info["errcode"].to_i > 0
    rescue Exception => e
      Rails.logger.error("Error:WeixinApi#get_api_token => #{e}")
    end

    return token_info
  end

  def self.get_open_id(appid, appsecret, code)
    token_info = {}
    url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{appsecret}&code=#{code}&grant_type=authorization_code"

    begin
      token_info = Oj.load(open(url).read)
      raise Exception.new("get open_id(#{code}) failed. token_info => #{token_info}") if token_info["errcode"].to_i > 0
    rescue Exception => e
      Rails.logger.error("Error:WeixinApi#get_open_id => #{e}")
    end

    return token_info
  end


  def self.get_api_ticket(token)
    ticket_info = {}
    url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{token}&type=jsapi"

    begin
      ticket_info = Oj.load(open(url).read)
      raise Exception.new("get access_ticket failed. ticket_info => #{ticket_info}") if ticket_info['errcode'].to_i > 0
    rescue Exception => e
      Rails.logger.error("Error:WeixinApi#get_api_ticket => #{e}")
    end

    return ticket_info
  end

  def self.upload_image(file_path)
    token = self.get_req_token(JUDU_WEIXIN_APP)
    retry_time = 3

    begin
      resp = `curl -F media=@#{file_path} "https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=#{token[:access_token]}&type=image"`
      if resp.blank?
        raise Exception.new('Curl command exec failed!')
      end

      resp_json = Oj.load(resp)

      if resp_json.has_key?('errcode') and resp_json['errcode'] != 0
        raise Exception.new("#{resp_json}")
      end

      return resp_json['media_id']

    rescue Exception => e
      Rails.logger.error("ERROR:Weixin.API.upload_blank_media => #{e}")
      retry_time -= 1
      retry if retry_time>0
    end
  end

  def self.download_media(media_id , refresh=false)
    token_info = self.get_req_token(WeixinApi::JUDU_WEIXIN_APP, refresh)
    req_token = token_info['access_token']
    retry_time = 3
    begin
      resp = HTTP.get('https://api.weixin.qq.com/cgi-bin/media/get',
                      params: {
                        access_token: req_token,
                        media_id: media_id
                      }
      )
      if resp.blank? or resp.code != 200 or resp.content_type.mime_type != 'audio/amr'
        raise Exception.new(resp.inspect)
      end
      resp.body.to_s
    rescue Exception => e
      Rails.logger.error("ERROR:Weixin.API.download_weixin_media => #{e}")
      token_info = WeixinApi.get_req_token(WeixinApi::JUDU_WEIXIN_APP, true)
      req_token = token_info['access_token']
      retry_time -= 1
      retry if retry_time > 0
    end
  end

  def self.refresh_token
    self.get_req_token(JUDU_WEIXIN_APP, true)
  end

  def self.get_req_token(app_config, refresh=false)
    cache_key = app_config['appid']
    cached_config = CacheConfig.find_by_key(cache_key)

    if refresh or cached_config.blank?
      token_info = self.get_api_token(app_config['appid'], app_config['appsecret'])
      ticket_info = self.get_api_ticket(token_info['access_token'].to_s)
      weixin_token = {'access_token' => token_info['access_token'].to_s, 'ticket' => ticket_info['ticket'].to_s}

      cache_attr = {
        'key' => cache_key,
        'value' => Oj.dump(weixin_token),
        'expired_at' => Time.now + token_info['expires_in'].to_i
      }
      cached_config.blank? ? CacheConfig.create(cache_attr) : cached_config.update_attributes(cache_attr)
    else
      weixin_token = Oj.load(cached_config.value)
    end

    return weixin_token
  end



  def self.get_weixin_share_config(app_config, share_from_url)
    wx_app_info = self.get_req_token(app_config)
    nonce_str = [*"a".."z", *"A".."Z", *"0".."9"].sample(16).join
    timestamp = Time.now.to_i
    signature = Digest::SHA1.hexdigest("jsapi_ticket=#{wx_app_info['ticket']}&noncestr=#{nonce_str}&timestamp=#{timestamp}&url=#{share_from_url}")

    return {
      'appId' => app_config['appid'],
      'timestamp' => timestamp,
      'nonceStr' => nonce_str,
      'signature' => signature
    }
  end

end
