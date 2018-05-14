OK = 1
FAIL=2
require  Rails.root.to_s+"/app/models/common/b_utils.rb"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  before_filter :add_cors_headers,:rename_upload_file

  rescue_from Exception, with: :show_error

  def  get_user
    access_token = cookies[:access_token] || params[:access_token]
    if access_token.blank?
      raise Exception.new("没有登录")
    end

    @user = User.where(:access_token => access_token).first

    if @user
      @user.password=nil;
    end

    if access_token.blank?
      raise Exception.new("登录过期")
    end


  end

  def add_cors_headers
    headers['Access-Control-Allow-Origin'] = "*"
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization,cookie'
  end



  def show_error(exception)
    Rails.logger.error "======error happened======"
    Rails.logger.error exception.message.inspect
    Rails.logger.error "#{exception.backtrace.join("\n\t")}"

    @exception = exception
    respond_to do |format|
      format.html {render 'layouts/error'}
      format.json {render json:{status:FAIL,msg:exception.message},:status => 200}
    end
  end

  def respond_to_ok(data,msg)
    respond_to do |format|
      format.json {render :json=>{status:OK,smsg:msg,data:data}}
    end
  end

  def options_result
      respond_to_ok(nil,"")
  end


  #处理文件上传
  def rename_upload_file
    if not BUtils.blank?params[:images]

      new_names = []
      params[:images].each do |file|
        org_name = file.original_filename
        prefix = BUtils.time_format_now() + "_" + rand(100000).to_s+"_";

        new_name = prefix + org_name;
        new_name_resize = "rs1_" + prefix+ org_name;

        BUtils.save_file(file.tempfile,new_name)
        Rails.logger.info("#{org_name} save as #{new_name}");

        from_path = BUtils.get_upload_file(new_name)
        to_path = BUtils.get_upload_file_path(new_name_resize)
        BUtils.resize_image(from_path,to_path,[600,450]);
        new_names << new_name;

      end

      params[:images] = new_names;
    end

  end


end
