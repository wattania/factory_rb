
class FileUpload < ActiveRecord::Base
  def self.remove_junk_file
    up = arel_table

    af = TbQuotationApproveFile.arel_table
    cf = TbQuotationCalculationFile.arel_table
    it = TbQuotationItem.arel_table
    cp = TbCustomerProperty.arel_table 
  
    models = [af, cf, it, 
      { model: cp, field: :doc_approved_file_hash}
    ]

    stmt = up.project([up[:file_hash]]).where(up[:created_at].lt(Date.current - 2.day))

    models.each{|mm| 
      if mm.is_a? Hash
        stmt.join(mm[:model], Arel::Nodes::OuterJoin).on(mm[:model][mm[:field]].eq up[:file_hash]) 
      else
        stmt.join(mm, Arel::Nodes::OuterJoin).on(mm[:file_hash].eq up[:file_hash]) 
      end
    }

    stmt.distinct
    
    used_hashs = []  
    find_by_sql(stmt).each{|row| used_hashs.push row.file_hash }
    used_hashs.uniq

    where.not(file_hash: used_hashs).delete_all
    FileUploadMetum.where.not(file_hash: used_hashs).delete_all
  end

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

