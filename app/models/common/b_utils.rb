require 'mini_magick'
require 'fileutils'

class BUtils

  def self.token
      key = "#{DateTime.now().to_i}#{rand(1000000)+2000}"
      ret = Digest::SHA1.hexdigest(key)
      return ret;
  end

  def self.domain
    #"localhost"
    "www.coderlong.com"
  end

  def self.time_format(t)
    t.strftime('%Y%m%d%H%M%S')
  end

  def self.time_format_now
    self.time_format(Time.now())
  end

  def self.blank?(s)
    return true if s.nil?

    if s.is_a? Array
      return s.size == 0
    end

    if s.is_a? String
      return  s =~ /^\s*$/
    end
  end

  def self.save_file(from_file, to_file_name)
    base_dir = "#{Rails.root.to_s}/public/upload/"
    new_file_name = "#{base_dir}/#{to_file_name}"
    FileUtils.copy(from_file,new_file_name)
  end

  def self.get_upload_file_path(file_name)
    return nil if blank?(file_name)

    base_dir = "#{Rails.root.to_s}/public/upload/"
    file_path = "#{base_dir}/#{file_name}"
    return file_path
  end

  def self.get_upload_file(file_name)
    return nil if blank?(file_name)
    file_path = get_upload_file_path(file_name)
    return nil unless File.exist?file_path
    return file_path
  end

  def self.calcute_new_size(old_size,standard_size)
    old_width,old_height = old_size.first,old_size.last
    s_width,s_height = standard_size.first,standard_size.last
    rate_info = (old_width.to_f / old_height.to_i)*100.round
    s_rate = (s_width.to_f / s_height.to_i)*100.round

    if rate_info < s_rate
      new_w = (s_height * old_width.to_f / old_height.to_f).round
      [new_w,s_height]
    else
      new_h = (s_width * old_height.to_f / old_width.to_f).round
      [s_width,new_h]
    end
  end



  #调整分辨率
  def self.resize_image(source_path,dest_path,standard_size=[800,600])
    origin_img = MiniMagick::Image.open(source_path)
    old_size = [origin_img[:width],origin_img[:height]]
    new_size = calcute_new_size(old_size,standard_size)
    origin_img.resize(new_size.join("x"))
    origin_img.write dest_path
    origin_img.destroy!
  end


  def self.send_ems(code)

    return true;
  end



  #下载url到某个文件
  def self.download(url,filepath)
    begin
      File.open(filepath, "wb") do |saved_file|
        # the following "open" is provided by open-uri
        open(url, "rb") do |read_file|
          saved_file.write(read_file.read)
        end
      end
      return true
    rescue => e
      puts e.message
      puts e.backtrace
      return nil
    end
    return nil
  end


  def self.zip_files(file_list, zip_file_path)
    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
      file_list.each do |file_path|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(File.basename(file_path),file_path)
      end
    end

  end


end
