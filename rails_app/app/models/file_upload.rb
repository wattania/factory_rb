class FileUpload < ActiveRecord::Base
  def self.file_upload_path
    Rails.root.join 'files'
  end

  def self.store a_file_data#file_param, a_uploaded_by
    hash = Digest::SHA1.hexdigest a_file_data

    ret = where(file_hash: hash).first
    if ret.blank?
      ret = FileUpload.create! file_hash: hash, file_size: a_file_data.size, file_data: FileUpload.zip(a_file_data)
    end

    ret
  end

  def zip a_file_data
    stringio = Zip::ZipOutputStream::write_buffer do |zio|
      zio.write a_file_data
    end
    stringio.rewind
    stringio.sysread
  end

  def upzip a_compressed_data

  end
end

