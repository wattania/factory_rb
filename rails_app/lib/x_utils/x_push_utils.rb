require "utilities"

class XPushUtils
  def self.tab_message a_message_json, a_tab_name, a_username = nil, a_main_pushid = nil
    redis = Redis.new(:host => Utils::Func.get_server_setting['redis']['host'])
    key = "tab"
    if a_username.nil?
      key = "tab:#{a_tab_name}:push_ids"
    else
      key = "tab_user:#{a_tab_name}#{a_username}:push_ids"
    end
 
    push_ids = redis.smembers key
 
    unless a_main_pushid.nil?
      push_ids.push a_main_pushid
      push_ids.uniq!
    end

    push_ids.each{|push_id|
      redis.publish push_id, a_message_json
    }

    redis.quit
  end
  
  def self.room_message a_message_json, a_room_name, a_redis = nil
    begin
      if a_redis.nil?
        redis = Redis.new(:host => Utils::Func.get_server_setting['redis']['host'])
      else
        redis = a_redis
      end

      push_ids = redis.smembers "#{a_room_name}:push_ids"
      push_ids.each{|push_id|
        redis.publish push_id, a_message_json
      }
      redis.quit if a_redis.nil?
    rescue Exception => e
      puts "--- room_message error ----"
      puts e.message
      puts e.backtrace
    end
  end
end