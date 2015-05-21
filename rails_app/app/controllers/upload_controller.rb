class UploadController < ApplicationController
  def file_upload
    begin
      ret = { data: FileUpload.file(params[:file], current_user.uuid) }
    rescue Exception => e
      ret = { error: { message: e.message, backtrace: e.backtrace } }
    end
    
    render json: ret
  end
end
