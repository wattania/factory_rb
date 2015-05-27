require 'rails_helper'

RSpec.describe TbQuotationItem, type: :model do
  describe "#validate_xml" do
    before :each do 
      @file_path = Rails.root.join 'spec', 'fixtures', 'import_file.xlsx'
    end

    it "ไม่ผ่าน" do
      
      n = FileUpload.new
      n.set_file_data File.open(@file_path, 'rb'){|f| f.read }
      n.content_type = 'xlsx'
      n.save!

      ret = TbQuotationItem.validate_xml n, UUID.generate, 'test', 'test'
      expect(ret.first).to be false
    end 

    it "ผ่าน" do 
      FactoryGirl.create :ref_part_name, display_name: 'Board'
      FactoryGirl.create :ref_part_name, display_name: 'Screw'
      FactoryGirl.create :ref_part_name, display_name: 'Spring'
      FactoryGirl.create :ref_part_name, display_name: 'Ruler'
      FactoryGirl.create :ref_part_name, display_name: 'Pencil'
      FactoryGirl.create :ref_part_name, display_name: 'Sponge'
      FactoryGirl.create :ref_part_name, display_name: 'Pen'

      FactoryGirl.create :ref_unit_price, display_name: 'THB'

      FactoryGirl.create :ref_model, display_name: 'Q4567'

        

      n = FileUpload.new
      n.set_file_data File.open(@file_path, 'rb'){|f| f.read }
      n.content_type = 'xlsx'
      n.save!

      ret = TbQuotationItem.validate_xml n, UUID.generate, 'test', 'test'
      expect(ret.first).to be true
    end
  end
end
