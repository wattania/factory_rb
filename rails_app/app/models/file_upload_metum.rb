class FileUploadMetum < ActiveRecord::Base
  def self.file m, file_name, user
    n = where(file_hash: m.file_hash).where(file_name: file_name).first
    if n.blank?
      n = FileUploadMetum.new 
      n.file_hash = m.file_hash
      n.file_name = file_name
      n.uploaded_by = user.uuid
      n.save!
    end
    n
  end
end
