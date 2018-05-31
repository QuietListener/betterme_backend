class ClientVersion < ActiveRecord::Base

  IOS = 1
  ANDROID = 3

  def self.getLatestIOS
    return ClientVersion.where(:client_type => IOS).order("created_at desc").first
  end

  def self.getLatestAndroid
    return ClientVersion.where(:client_type => ANDROID).order("created_at desc").first
  end

end
