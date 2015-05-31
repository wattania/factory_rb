class UploadController < ApplicationController
  def file_upload

    begin
      m = FileUpload.store(params[:file].tempfile.read, params[:file].content_type)
      FileUploadMetum.file m, params[:file].original_filename, current_user
      ret = { data: { hash: m.file_hash, filename: params[:file].original_filename }}
    rescue Exception => e
      ret = { error: { message: e.message, backtrace: e.backtrace } }
    end
    
    render json: ret
  end

  def download
    FileUpload.where(file_hash: params[:id]).limit(1).each{|f|
      send_data(f.get_file_data, {filename: params[:filename], type: params[:type] })
    }
  end

  def get_file
    path = Rails.root.join('tmp', params[:id])
    data = File.open(path, 'rb'){|f| f.read }
    File.delete path
    send_data(data, {filename: params[:filename], type: params[:type] })
  end
end
