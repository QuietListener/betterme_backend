#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'
require("#{Rails.root.to_s}/app/models/learn_word.rb")

UsedScorePerDay = 50;
InitScore = 2100;
VideosPerPage = 50
WordsPerPage = 100

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
      access_token = params[:access_token] if access_token.blank?

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

    @utypes = Utype.where("`status` != ?",Utype::TypeStatusDelete)

  end

  def createOrUpdate
    video = Video.new;
    if params[:id] and params[:id].strip != ""
      video = Video.where(:id=>params[:id]).first
    end

    video.title = params[:title]
    video.title_cn = params[:title_cn]
    video.video_url = params[:video_url]
    video.srt_url = params[:srt_url]
    video.srt_file_name = params[:srt_file_name]
    video.video_file_name = params[:video_file_name]
    video.other_srt_file_name = params[:other_srt_file_name]
    video.other_srt_url = params[:other_srt_url]
    video.poster = params[:poster]
    video.utype_id=params[:utype_id]

    video.save!
    redirect_to "/dict/video?id=#{video.id}"
  end

  def api_utypes
    @utypes = Utype.where("`status` != ?",Utype::TypeStatusDelete)
    respond_to_ok(@utypes,"ok")
  end

  def api_videos
    if params[:utypes] and params[:utype_id] >= 0
      @videos_ = Video.where(:utype_id => params[:utype_id]).paginate(:page => params[:page], :per_page => VideosPerPage)
    else
      @videos_ = Video.paginate(:page => params[:page], :per_page => VideosPerPage)
    end

    respond_to_ok({videos:@videos_,total_page:@videos_.total_pages},"ok");
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
    if params[:video_id] and params[:video_id].strip != ""
        learn_word = UserLearnWord.where(:user_id => @user.id,:video_id=>params[:video_id]).order("updated_at desc").paginate(:page => params[:page], :per_page => WordsPerPage)
    else
      learn_word = UserLearnWord.where(:user_id => @user.id).order("updated_at desc").paginate(:page => params[:page], :per_page => WordsPerPage)
    end

    learn_word_ok = learn_word.map do |item|
      item.as_json(:include=>[:learn_word,:video])
    end

    respond_to_ok({words:learn_word_ok,total_page:learn_word.total_pages},"ok");
  end



  def like_video
    params[:type]=UserVideo::TypeLike
    return create_video_user_status()
  end


  def watch_video
    params[:type]=UserVideo::TypeWatched
    create_video_user_status()
    respond_to_ok({},"ok");
  end

  def create_video_user_status
    if params[:video_id] == nil or params[:video_id] == ""
        raise Exception.new("video_id 为空")
    end

    v = Video.where(:id=>params[:video_id]).first
    type = params[:type]
    if (type == UserVideo::TypeLike or type == UserVideo::TypeWatched) and v != nil

      uv = UserVideo.where(:user_id => @user.id,:video_id=> params[:video_id],:uvtype => type).first

      if not uv
        u = UserVideo.new
        u.user_id = @user.id
        u.video_id= v.id
        u.uvtype=type
        u.save!
      end

      package_id = params[:package_id]
      if(type == UserVideo::TypeWatched) and package_id

        package =  Package.where(:id=>package_id).first

        if package and package.finished(@user.id) == true

          up1 =  UserPackage.where(:user_id => @user.id,:package_id => package_id,:ttype => UserPackage::TypeFinished).first;

          return if  up1 #如果已经完成了就不用了

          up =  UserPackage.where(:user_id => @user.id,:package_id => package_id,:ttype => UserPackage::TypePlayed).first;

          up = UserPackage.new if not up

          up.package_id = package.id
          up.user_id=@user.id
          up.ttype=UserPackage::TypeFinished
          up.save;

        end

      end

    else
      raise Exception.new("失败 视频不存在或者类型不存在");
    end

  end

  def packages
    @packages  = Package.paginate(:page => params[:page], :per_page => 10)
  end


  def package
    @package = Package.new
    if params[:id]
      @package = Package.find(params[:id])
    end
  end



  def createOrUpdatePackage
    package = Package.new;
    if params[:id] and params[:id].strip != ""
      package = Package.where(:id=>params[:id]).first
    end

    package.title = params[:title]
    package.poster = params[:poster]
    package.title_cn=params[:title_cn]
    package.desc=params[:desc]

    package.save!
    redirect_to "/dict/package?id=#{package.id}"
  end


  def add_video_2_package
    package = Package.find(params[:package_id])
    video = Video.find(params[:video_id])

    if package and video
      package.add_video(video.id)
    end

    redirect_to "/dict/package?id=#{package.id}"

  end


  def remove_video_from_package
    package = Package.find(params[:package_id])
    video = Video.find(params[:video_id])

    if package and video
      package.remove_video(video.id)
    end

    redirect_to "/dict/package?id=#{package.id}"

  end

  def typed_videos(type)
    uvs = UserVideo.where(:type=>type, :user_id => @user.id).order("created_at desc").paginate(:page => params[:page], :per_page => 20)
    vids = uvs.map {|uv| uv.video_id}

    videos = Video.where(:id=>vids)

    respond_to_ok({vidoes:videos,total_pages:uvs.total_pages},"ok");

  end


  def liked_videos
    return typed_videos(UserVideo::TypeWatched)
  end

  def watched_videos
    return typed_videos(UserVideo::TypeWatched)
  end

  def api_packages
    @packages  = Package.paginate(:page => params[:page], :per_page => 10)
    respond_to_ok({packages:@packages, total_page:@packages.total_pages},"ok");
  end


  def api_package
    @package = Package.where(:id=>params[:id]).first

    package = @package.as_json(:include=>[:videos])
    count = UserPackage.where(:user_id => @user.id, :package_id => @package.id,:ttype=>UserPackage::TypeLike).count

    package[:like] = count > 0
    package[:finished] = @package.finished(@user.id)

    ups = UserVideo.where(:user_id => @user.id).pluck(:video_id,:uvtype)
    package[:videos_status] = ups.as_json;

    respond_to_ok( package,"ok");
  end


  def api_add_package
    @package = Package.find(params[:package_id])

    user = User.find(@user.id)
    user.package_id=@package.id
    user.save!

    if not user.package_exists(@package.id,UserPackage::TypeFinished)
      @user.add_package(params[:package_id],UserPackage::TypePlayed)
    end

    respond_to_ok(user,"ok")
  end

  def api_like_package
    @user.add_package(params[:package_id],UserPackage::TypeLike)

    respond_to_ok(params[:package_id],"ok")
  end

  def api_play_package
    @user.add_package(params[:package_id],UserPackage::TypePlayed)
    respond_to_ok(@user,"ok")
  end

  def api_unlike_package
    @user.remove_package(params[:package_id],UserPackage::TypeLike)
    respond_to_ok(params[:package_id],"ok")
  end


  def api_my_packages
      ups = []
      if not params[:ttype].blank?
        ups = UserPackage.where(:user_id=>@user.id,:ttype => params[:ttype])
      else
        ups = UserPackage.where(:user_id=>@user.id)
      end


      ups_ = ups.map{|up| up.as_json(:include=>[:package])}
      respond_to_ok(ups_,"ok");
  end

  def api_my_videos
      uvs = UserVideo.where(:user_id => @user.id)
      @uvs = uvs.map{|uv|  uv.as_json(:include=>[:video])}
      respond_to_ok(@uvs,"ok");
  end

  def api_statistics
      watched_video = UserVideo.where(:user_id => @user.id,:uvtype => UserVideo::TypeWatched).pluck(:video_id,:created_at).map{|item| [item[0], item[1].strftime('%Y-%m-%d').to_s]}

    finished_package_count = UserPackage.where(:user_id => @user.id,:ttype => UserPackage::TypeFinished).count()

    watched_video_count = watched_video.size();

    watched_videos = Video.where(:id=>watched_video.map{|item|item[0]});
    listen_word_count = watched_videos.inject(0){|t,v|t+=v.words_count; t};

    ret = {watched_video:watched_video,finished_package_count:finished_package_count,watched_video_count:watched_video_count,listen_word_count:listen_word_count}

    respond_to_ok(ret,"ok");
  end

  def api_latest_version
     client_type = params[:client_type]
     cv = ClientVersion.where(:client_type=>client_type).order("created_at desc").first

     if cv.blank?
       cv = {}
     end

     respond_to_ok(cv,"ok");
  end

end


