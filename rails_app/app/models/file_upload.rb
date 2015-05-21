class FileUpload < ActiveRecord::Base
  def self.file_upload_path
    Rails.root.join 'files'
  end

  def self.file file_param, a_uploaded_by
    file_name = file_param.original_filename

    upload_path = FileUpload.file_upload_path
    Dir.mkdir upload_path unless Dir.exists? upload_path
    
    file_data = file_param.tempfile.read()
    hash = Digest::SHA1.hexdigest file_data

    file_path = Rails.root.join 'files', "#{hash}"
    unless File.exists? file_path
      File.open file_path, "wb" do |f|
        f.write file_data
      end
    end

    row = FileUpload.where(file_hash: hash).where(file_name: file_name).first
    if row.blank?
      FileUpload.create! file_name: file_name, file_hash: hash, file_size: file_data.size, uploaded_by: a_uploaded_by
    else
      row
    end
  end

  def self.get_data_by_hash hash
    file_data = nil
    file_path = FileUpload.file_upload_path.join hash
    File.open(file_path, "rb"){|f| file_data = f.read }
    file_data
  end

  def self.get_path_by_hash hash 
    path = file_upload_path.join hash
    if File.exists? path
      path
    else
      ""
    end
  end
end

