class BUtils

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

  def self.get_upload_file(file_name)
    return nil if blank?(file_name)

    base_dir = "#{Rails.root.to_s}/public/upload/"
    file_path = "#{base_dir}/#{file_name}"

    return nil unless File.exist?file_path
    return file_path
  end

end
