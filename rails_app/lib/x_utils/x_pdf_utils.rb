if defined?(JRUBY_VERSION)
  java_import java.io.FileOutputStream
  java_import java.io.IOException
  java_import java.sql.SQLException
 
  java_import Java::ComItextpdfText::Document
  java_import Java::ComItextpdfText::DocumentException
  java_import Java::ComItextpdfTextPdf::PdfCopy
  java_import Java::ComItextpdfTextPdf::PdfReader

end
class XPdfUtils
  def self.concat file_hashs 
    if defined?(JRUBY_VERSION)  

      ret = UUID.new.generate
     
      document = Document.new 
      copy = PdfCopy.new document, FileOutputStream.new( Rails.root.join('tmp', ret).to_s )
      document.open

      file_hashs.each{|h| 
        tmp_path = Rails.root.join('tmp', h).to_s

        reader = PdfReader.new tmp_path
        (0...reader.getNumberOfPages).each{|page| copy.add_page copy.get_imported_page(reader, page + 1) }
        copy.free_reader reader
        reader.close

        File.delete tmp_path
      }

      document.close
      
      ret 
    else
    end
  end
end