class Settings::UserController < ResourceHelperController
  before_filter :check_is_admin

  def check_is_admin
    unless current_user.is_admin
      return render json: {success: false, message: 'Unauthorize!'}
    end
  end

  def index_list result
    ur = User.arel_table
     
    projects = {
      "record_id"   => ur[:id],
      "lock_version"=> ur[:lock_version],
      "user_name"   => ur[:user_name],
      "first_name"  => ur[:first_name],
      "last_name"   => ur[:last_name],
      "email"       => ur[:email],
      "last_sign_in_at" => ur[:last_sign_in_at],
      "locked_at"   => ur[:locked_at],
      'locked_at_'  => XModelUtils.timestamp(ur[:locked_at]),
      'last_sign_in_at_'  => XModelUtils.timestamp(ur[:last_sign_in_at]),
      "is_admin"    => ur[:is_admin]
    }

    stmt = ur.project(project_stmt projects).order(ur[:user_name])
    
    result[:total]  = result_total stmt
    rows   = result_rows stmt, projects do |prop|
      case prop
      when "locked_at_"
        ur[:locked_at]
      when 'last_sign_in_at_'
        ur[:last_sign_in_at]
      end
    end

    user = current_user

    result[:rows] = []
    rows.each{|row|
      tmp = JSON.parse row.to_json
      tmp["last_sign_in_at_"] = row.last_sign_in_at.in_time_zone(user.get_timezone).strftime "%d/%m/%Y %H:%M:%S"
      unless row.locked_at.blank?
        tmp["locked_at_"]       = row.locked_at.in_time_zone(user.get_timezone).strftime "%d/%m/%Y %H:%M:%S"
      end
      result[:rows].push tmp
    }
  end

  def create_form_new result
  end

  def __update_user user
    user.password               = params[:data][:password] unless params[:data][:password].blank?
    user.password_confirmation  = params[:data][:password_confirmation] unless params[:data][:password_confirmation].blank?
    
    unless params[:data][:lock]
      user.locked_at = nil 
    else
      user.locked_at = DateTime.current
    end

  end

  def create_form_data result
    user = User.new
    user.fn_create_record_data params[:data]
    
    
    save_record result, user 
    result[:id] = user.id
  end

  def create_new result
    data = params[:data] || {}

    m = User.new
    m.fn_create_record_data data
    __update_user m

    save_record result, m
  end

  def show_form_edit result
    m = User.find params[:id]
    result[:rows] = JSON.parse m.to_json
    result[:rows]["lock"] = !m.locked_at.blank?
  end

  def update_edit result
    m = User.find params[:id]
    m.fn_update_record_data params[:data]
    __update_user m 
    save_record result, m
  end
end
