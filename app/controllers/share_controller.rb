#encoding:utf-8
#配置任务
require 'digest/sha1'
require "#{Rails.root.to_s}/lib/weixin_api.rb"

class ShareController < ApplicationController
  #protect_from_forgery
  # skip_before_filter :login_filter,:only => [:login,:logout,:index,:register]
  # before_filter :login_filter,only: [:user_info]
end