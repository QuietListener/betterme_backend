#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'

UsedScorePerDay = 50;
InitScore = 2100;

class DictController < ApplicationController
  #
  # before_filter :add_cors_headers,:get_user,
  #               :except => [:search_word,:index,:login,:videos,:register,:ensure_code,:test1,:video,:createOrUpdate]

  def search_word
    word = params[:word]

    respond_to_ok({
        word: { word:"custom",
                accent:"['kʌstəm]",
                mean_cn:"n. 习惯，惯例；风俗；海关，关税；经常光顾；[总称]（经常性的）顾客; adj. （衣服等）定做的，定制的"
            },
        recomend:[]},"ok")
  end


  def videos
    @videos  = Video.paginate(:page => params[:page], :per_page => 10)
  end

  def video
    @video
    if params[:id]
      @video = Video.find(params[:id])
    end

  end

  def createOrUpdate
    video = Video.new;
    if params[:id]
      video = Video.find(params[:id])
    end

    video.title = params[:title]
    video.video_url = params[:video_url]
    video.srt_url = params[:srt_url]
    video.srt_file_name = params[:srt_file_name]
    video.video_file_name = params[:video_file_name]
    video.poster = params[:poster]

    video.save!
    redirect_to "/dict/video?id=#{video.id}"
  end


  def api_videos
    @videos_ = Video.paginate(:page => params[:page], :per_page => 10)
    respond_to_ok(@videos_,"ok")
  end
end

