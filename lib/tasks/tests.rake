#encoding: utf-8

# desc "Explaining what the task does"
require 'fileutils'
base = "#{Rails.root.to_s}"

require "#{base}/app/models/common/b_utils.rb"
public = "#{base}/public/"


task :test_resize_img  => :environment do
  imgbase = "#{base}/lib/tasks/test_resources/"
  files = ["20180121120933_54443_2.png","20180127224312_67557_image.jpg"]

  files.each do |f|
    path = "#{imgbase}/#{f}"
    dpath = "/tmp/#{f}"

    BUtils.resize_image(path, dpath)
  end


end
