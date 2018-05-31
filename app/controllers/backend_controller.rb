#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'
require("#{Rails.root.to_s}/app/models/learn_word.rb")

UsedScorePerDay = 50;
InitScore = 2100;
VideosPerPage = 50
WordsPerPage = 100

class BackendController < ApplicationController

  before_filter :add_cors_headers,:get_user,
                :except => [:users]


  def users
    @uall = User.order("created_at desc").paginate(:page => params[:page], :per_page => 10)
  end



  def latest_version
    @cv_ios = ClientVersion.getLatestIOS();
    @cv_android = ClientVersion.getLatestAndroid()

  end

  def add_new_client_version
    client_type = params[:client_type]

    if !client_type.blank? and  [ClientVersion::IOS,ClientVersion::ANDROID].include?(client_type.to_i)
      cv = ClientVersion.new
      cv.client_type=client_type
      cv.version=params[:version]
      cv.download_url = params[:download_url]
      cv.desc = params[:desc]
      cv.save!
    end

    redirect_to :action => :latest_version

  end

end


