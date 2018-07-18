#encoding:utf-8
require("#{Rails.root.to_s}/app/models/common/b_utils.rb")
require 'digest/sha1'
require("#{Rails.root.to_s}/app/models/question_word.rb")

UsedScorePerDay = 50;
InitScore = 2100;

class CpController < ApplicationController

  before_filter :add_cors_headers,:get_user,:except => [:search_word,:index,:login,:register,:ensure_code,:test1]


  def start_compete

     cpSession = CpSession.where("user2_id <= 0",0).first

     #创建一个
     if not cpSession

        cpSession = CpSession.new
        cpSession.user1_id=@user.id

        qws,choices = QuestionWord.getQuestion(4)
        words_ids = qws.map{|qw| qw.id}
        choices_words_id = choices.map{|qw|qw.id}

        cpSession.words_ids=words_ids.join(",");
        cpSession.choices_words_ids=choices_words_id.join(",");

        cpSession.save!
     else
       cpSession.with_lock do
         cpSession.user2_id=@user.id
         cpSession.save!
       end
     end

    respond_to_ok(cpSession.as_json_data,"ok")

  end


  def compete_stat
    cpSession = CpSession.where(:id=>params[:id]);
    if(@user.id != cpSession.user1_id || @user.id != cpSession.user2_id)
      raise Exception.new("你不在这场比赛")
    end

    respond_to_ok(cpSession.as_json_data,"ok")
  end


  def post_compete_data
    cpSession = CpSession.where(:id=>params[:id]);

    cpSession.with_lock do

      if(@user.id != cpSession.user1_id || @user.id != cpSession.user2_id)
        raise Exception.new("你不在这场比赛")
      end

      user_choices = params[:user_choices]||""
      used_time = params[:used_time]||""

      user_choices_array = user_choices.split(",")
      question_idx = params[:question_idx]

      if @user.id == cpSession.user1_id
        cur_idx = cpSession.user1_idx

        cpSession.user1_idx = question_idx
        cpSession.user1_choices = user_choices;
        cpSession.user1_used_time = used_time;

      else
        cur_idx = cpSession.user2_idx
        cpSession.user2_idx = question_idx
        cpSession.user2_choices = user_choices;
        cpSession.user2_used_time = used_time;
      end

      cpSession.save!
    end
      
    respond_to_ok(cpSession.as_json_data,"ok")
  end

end

