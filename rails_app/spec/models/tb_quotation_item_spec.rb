require 'rails_helper'

RSpec.describe TbQuotationItem, type: :model do
  describe "#validate_xml" do
    it "pass" do
      path = Rails.root.join 'spec', 'fixtures', 'import_file.xlsx'
      n = FileUpload.new
      n.set_file_data File.open(path, 'rb'){|f| f.read }
      n.content_type = 'xlsx'
      n.save!


      t = Tempfile.new ["#{Time.now.usec}", '.xlsx']
      t.binmode

      TbQuotationItem.validate_xml n, t

      t.close
      t.unlink

    end 
  end
end
