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

end


