class XLogging
  attr_accessor :uuid, :is_to_file

  def initialize is_to_file = true
    @uuid = UUID.new.generate
    @msg = []
    @is_to_file = is_to_file
    @path = Rails.root.join('tmp', 'logging')
  end

  def logging_add msg
    @msg.push "#{msg}</br></br>"           
  end

  def result
    @msg.join ''
  end

  def to_file
    
    FileUtils::mkdir_p @path
    File.open @path.join("#{@uuid}.log"), 'w' do |f|
      f.write result
    end
    @uuid
  end

  def self.read_logfile uuid
    ret = ""
    log_file = Rails.root.join('tmp', 'logging', "#{uuid}.log")
    begin
      File.open log_file, 'r' do |f|
        ret = f.read
      end  

      File.delete log_file
    rescue Exception => e
      ret = e.message
    end
    ret
  end
end