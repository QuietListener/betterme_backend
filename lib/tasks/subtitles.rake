#encoding: utf-8

# desc "Explaining what the task does"
require 'fileutils'
base = "#{Rails.root.to_s}"

require "#{base}/app/models/common/b_utils.rb"
public = "#{base}/public/"

require 'nokogiri'
require 'open-uri'
require 'httpclient'

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


#没有resize的图片
task :grab_lavafox  => :environment do
  # create Mechanize instance

  url_ = 'http://www.lavafox.com/study-movie.aspx?Mid=202&&Sid=4549'
  url = URI.parse url_

  cookies = {"ASP.NET_SessionId"=>"pxv3qvoqg0trfviueisca0ob","UM_distinctid"=>"162d6795e36627-0089ea74b098f9-336b7b05-fa000-162d6795e372f6","CNZZDATA1000377994"=>"1685663423-1525249860-%7C1525321232","LoginInfo"=>"userEmail=yangtingjun1@gmail.com&userName=buptjunjun&userpass=76756"}


  client = HTTPClient.new
  cookies.each do |k,v|
    puts "#{k}->#{v}"
    cookie = WebAgent::Cookie.new(k,v)
    cookie.name = k
    cookie.value = v
    cookie.url = url

    client.cookie_manager.add cookie
  end


   res = client.get url
  doc = Nokogiri::HTML(res.body)

  title_text = doc.css("section.page-top font").text
  title = title_text.strip
  puts title

  dom_video = doc.at_css("video#home_video")

  puts "-------"
  #puts dom_video

  if dom_video
      poster = dom_video.attr("poster")
      video_url =   dom_video.at_css("source").attr("src")
      tracks = dom_video.css("track")

      srt = nil
      srt_en = nil
      srt_ce = nil
      tracks.each do |item|
        src = item.attr("src")
        label =  item.attr("label")

        host = "http://www.lavafox.com/"
        subtitle_url = "#{host}#{src}"
        if label=="中英文"
          srt_ce = subtitle_url
        elsif label = "英文"
          srt_en = subtitle_url
        end
      end


      title = title_text.gsub(/^[\(|\)|）|（]/,"")
      ret = {title:title,poster:poster, video_url:video_url, srt_en:srt_en, srt_ce:srt_ce}
      puts ret ;
  end

  #puts dom_video.html

end