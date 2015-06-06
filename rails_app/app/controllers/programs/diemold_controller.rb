class Programs::DiemoldController < ResourceHelperController  
  def index_list result
    filter = {}
    unless params[:filter].blank?
      filter = JSON.parse(params[:filter])
    end
    stmt = TbDieMold.index_list_stmt filter
    result[:rows] = result_rows stmt
    result[:total] = result_total stmt
  end

  def update_upload result
    up = FileUpload.where(file_hash: params[:id]).first
    unless up.blank?
      ret = TbDieMold.validate_xml up, current_user
      result[:valid] = ret.first
      unless ret.first
        result[:html] = ret[2]
        raise ActiveRecord::Rollback
      end
    else
      raise "File Invalid!"
    end
  end

  def create_export_all result
    result[:hash] = TbDieMold.export_all params[:filter]
  end
end
