
class FileUpload < ActiveRecord::Base
  def self.file_upload_path
    Rails.root.join 'files'
  end

  def self.store a_file_data, a_content_type 
    hash = Digest::SHA1.hexdigest a_file_data

    ret = where(file_hash: hash).first
    if ret.blank?
      n = FileUpload.new 
      n.set_file_data a_file_data
      n.content_type = a_content_type
      n.save!
      ret = n
    end

    ret
  end

  def self.__zip a_file_data
    ret = Zip::OutputStream::write_buffer do |zio|
      zio.put_next_entry "data"
      zio.write a_file_data
    end 
    ret.rewind
    ret.read
  end

  def self.__unzip a_compressed_data
    ret = nil
    Zip::InputStream::open a_compressed_data do |io|
      while (entry = io.get_next_entry)
        ret = io.read
      end
    end
    ret
  end

  def get_file_data
    if new_record?
      FileUpload.__unzip self.file_data
    else
      FileUpload.__unzip StringIO.new self.file_data
    end
  end

  def set_file_data a_file_data  
    self.file_hash = Digest::SHA1.hexdigest a_file_data
    self.file_size = a_file_data.size
    self.file_data = FileUpload.__zip(a_file_data)
  end
end

