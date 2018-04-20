#encoding: utf-8

# desc "Explaining what the task does"
require 'fileutils'
base = "#{Rails.root.to_s}"

require "#{base}/app/models/common/b_utils.rb"
public = "#{base}/public/"


#没有resize的图片
task :split_subtites  => :environment do

  configPath = "/Users/junjun/Documents/项目/ruby/rubymine/betterme/docs/subtitles/forrest_gump/config.json"

  config = JSON.parse(File.new(configPath).read)
  puts config.as_json

  basedir = "#{Rails.root}/docs/subtitles/"

  fileName = "#{basedir}/#{config['srt_name']}"
  puts "srt file : #{fileName}";

  file = SRT::File.parse(File.new(fileName))

  config["splits"].each do |conf|

    puts "\r\n\r\ncut part #{conf}";

    t = Time.at(Time.parse(conf[1]) - Time.parse(conf[0])).utc();

    secondSplit = t.strftime("%H:%M:%S.%L")

    part = file.split(:at=>conf[0])[1].split(:at=>secondSplit)[0]
    part.timeshift( :all => "#{conf[2]}s")

    outputFilePath = "#{basedir}/#{conf[3]}"
    f = File.new(outputFilePath,"w")

    puts "writes to #{outputFilePath}"
    part.lines.each do |line|
      str =  "#{line.sequence}\r\n#{line.time_str}\r\n#{line.text.join("\r\n")}\r\n\r\n".force_encoding("utf-8")
      f.puts str;
    end

    f.close;
  end


end

