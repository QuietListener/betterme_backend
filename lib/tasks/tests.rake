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

#没有resize的图片
task :fix_resize_img  => :environment do
  imgbase = "#{public}/upload"

   Dir.entries(imgbase).each do |f|
     f_path = "#{imgbase}/#{f}";
     puts "fix_resize_img-#{f}";
     if f =="." or f == ".."  or File.directory? f_path
       next;
     end


     rs_f_path = "#{imgbase}/rs1_#{f}";

     puts("#{f_path} => #{rs_f_path}");

     if not File.exist? rs_f_path
       BUtils.resize_image(f_path, rs_f_path)
     end
   end

end

