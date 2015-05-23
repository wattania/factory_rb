class UploadController < ApplicationController
  def file_upload

    begin
      m = FileUpload.store(params[:file].tempfile.read, params[:file].content_type)
      FileUploadMetum.file m, params[:file].original_filename, current_user
      ret = { data: m.file_hash }
    rescue Exception => e
      ret = { error: { message: e.message, backtrace: e.backtrace } }
    end
    
    render json: ret
  end
end
