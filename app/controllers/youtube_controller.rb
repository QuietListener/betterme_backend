#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'

UsedScorePerDay = 50;
InitScore = 2100;

class YoutubeController < ApplicationController

  before_filter :add_cors_headers

  def index

  end


end

