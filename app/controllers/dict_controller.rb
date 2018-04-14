#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'
require("#{Rails.root.to_s}/app/models/learn_word.rb")

UsedScorePerDay = 50;
InitScore = 2100;

class DictController < ApplicationController
  #
  # before_filter :add_cors_headers,:get_user,
  #               :except => [:search_word,:index,:login,:videos,:register,:ensure_code,:test1,:video,:createOrUpdate]

  def search_word
    word = params[:word]

    @word = LearnWord.where(:word=>word).first

    if @word
      ret = { word: { word:@word.word, accent:@word.accent,  mean_cn:@word.mean_cn}, recomend:[]}
    else
      ret = nil
    end

    respond_to_ok(ret ,"ok")
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

