#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'
require("#{Rails.root.to_s}/app/models/learn_word.rb")

UsedScorePerDay = 50;
InitScore = 2100;

class DictController < ApplicationController

  before_filter :add_cors_headers,:get_user,
                :except => [:search_word,:index,:login,:videos,:register,:ensure_code,:test1,:video,:createOrUpdate]

  def search_word
    word = params[:word]

    @word = LearnWord.where(:word=>word).first

    saved = false
    logined = false;
    if @word
      access_token = cookies[:access_token]
      if access_token
        @user = User.where(:access_token => access_token).first
        @user.password=nil if @user
        if @user
          saved = UserLearnWord.where(:user_id => @user.id,:learn_word_id => @word.id).count > 0
          logined = @user ? true : false
        end
      end

      ret = { word: {id:@word.id,word:@word.word, accent:@word.accent, mean_cn:@word.mean_cn,saved:saved,logined:logined}, recomend:[]}
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
    video.other_srt_file_name = params[:other_srt_file_name]
    video.other_srt_url = params[:other_srt_url]
    video.poster = params[:poster]

    video.save!
    redirect_to "/dict/video?id=#{video.id}"
  end


  def api_videos
    @videos_ = Video.paginate(:page => params[:page], :per_page => 10)
    respond_to_ok(@videos_,"ok")
  end


  def save_word
    id = params[:id]
    word = LearnWord.where(:id=>id).first

    if not word
      raise Exception.new("没有这个单词")
    end

    ulw = UserLearnWord.where(:user_id => @user.id,:learn_word_id => word.id).first

    if ulw
      raise Exception.new("已经收藏过了喔~")
    end

    ulw = UserLearnWord.new
    ulw.user_id=@user.id
    ulw.learn_word_id=word.id
    ulw.status=UserLearnWord::StateOk

    ulw.video_id=params[:video_id]
    ulw.subtitle=params[:subtitle]

    ulw.save!

    respond_to_ok({},'收藏成功');
  end


  def my_words
    learn_word = UserLearnWord.where(:user_id => @user.id).paginate(:page => params[:page], :per_page => 10)
    learn_word_ok = learn_word.map do |item|
      item.as_json(:include=>[:learn_word,:video])
    end

    respond_to_ok({words:learn_word_ok,total_page:learn_word.total_pages},"ok");
  end

end


