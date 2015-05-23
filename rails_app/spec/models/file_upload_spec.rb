require 'rails_helper'

RSpec.describe FileUpload, type: :model do
  describe "store" do 
    it "store file to database" do 
      #FileUpload.store 

      path = Rails.root.join 'spec', 'fixtures', 'import_file.xlsx'
      data = File.open path, 'rb' do |f| f.read end

      n = FileUpload.new
      n.set_file_data data
      n.save!


      expect(FileUpload.all.size).to eq 1

      n = FileUpload.first
      zdata = n.get_file_data

     hash = Digest::SHA1.hexdigest zdata
     expect(hash).to eq n.file_hash

    end
  end
end
