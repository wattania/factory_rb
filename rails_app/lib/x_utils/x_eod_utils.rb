class XEodUtils
  def self.mini_backtrace backtrace 
    values = []
    found_rails_root = false
    (backtrace || []).each{|data|
      if found_rails_root
        break unless data.start_with? Rails.root.to_s 
      end
      values << data 
      unless found_rails_root
        if data.start_with? Rails.root.to_s
          found_rails_root = true
        end 
      end
    } 
    values
  end

  def self.get_program_details
    ret = {}
    eod_path = File.join(Rails.root, "eod", "tasks")
    prog_list = Dir.glob(File.join(eod_path, "prog*.rb"))

    prog_list.sort!

    prog_list.each_with_index{|prog, index|
      file_ = File.open(prog)
      file_data = file_.read
      file_.close
      
      begin_index = file_data.index("=begin")
      end_index   = file_data.index("=end", begin_index + "=begin".size)

      detail_string = file_data.slice(begin_index + "=begin".size, end_index - (begin_index + "=begin".size))
      id = Pathname.new(prog).basename.to_s.split("_")[0]
      id = id.slice(4, id.size)
      xx = JSON.parse(detail_string)
      xx["id"] = "#{id}"

      if ret[xx["id"]].nil?
        ret[xx["id"]] = xx
      else
        raise "Duplicate Program ID! #{xx["id"]}"
      end
    }
    return ret
  end
end