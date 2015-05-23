require 'rails_helper'

RSpec.describe UploadController, type: :controller do
  describe "#file_upload" do 
    login_admin
    it "upload file" do 
      file_name = 'import_file.xlsx'
      file_path = Rails.root.join 'spec', 'fixtures', file_name

      hash = Digest::SHA1.hexdigest File.open(file_path, 'rb'){|f| f.read }

      post :file_upload, file: ActionDispatch::Http::UploadedFile.new(
        {
          tempfile: File.new(file_path),
          type: 'xls', 
          filename: file_name
        }
      )

      res = JSON.parse response.body
      
      expect(res["data"]).to eq hash

      expect(FileUploadMetum.all.size).to eq 1
      expect(FileUpload.all.size).to eq 1

      meta = FileUploadMetum.first 
      expect(meta.file_hash).to eq hash 
      expect(meta.uploaded_by.to_s.size).to be > 0
      expect(meta.file_name).to eq file_name

      upload = FileUpload.first 
      expect(upload.file_hash).to eq hash
      expect(upload.content_type).to eq 'xls'

      ############################################################
      post :file_upload, file: ActionDispatch::Http::UploadedFile.new(
        {
          tempfile: File.new(file_path),
          type: 'xls', 
          filename: file_name + "_01"
        }
      )

      expect(res["data"]).to eq hash

      expect(FileUploadMetum.all.size).to eq 2
      expect(FileUpload.all.size).to eq 1

      p FileUploadMetum.where(file_name: file_name + "_01").first
    end
  end
end
