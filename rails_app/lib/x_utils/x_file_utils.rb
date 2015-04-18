# To change this template, choose Tools | Templates
# and open the template in the editor.
class XFileUtils
  def self.store_tmp_file a_file_data
    hash = Digest::SHA1.hexdigest(a_file_data || "")
    path = Rails.root.join 'tmp', hash
    File.open(path, 'wb') { |f| f.write(a_file_data) }
    hash
  end

  def self.get_tmp_file_by_hash a_hash, delete = true
    file_data = ""
    path = Rails.root.join 'tmp', a_hash
    File.open(path, 'rb') { |f| file_data = f.read}
    File.delete path if delete
    file_data
  end

  def self.get_tmp_data file_name=nil
#    file_name = params[:file_name]
    data = {}
    unless(file_name.blank?)
      path = "#{Rails.root.join('tmp',file_name)}"
      data = YAML.load_file(path) || {} 
    end
#    puts "XFileUtils"
#    p data
    return data
  end
end
