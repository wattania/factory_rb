require "xmlrpc/client"

class Wordpress
  attr_accessor :xmlrpc_server
  def initialize
    wp_admin = nil
    wp_password = nil
    wp_host = nil

    SysConfig.where(config_key: ['wp_admin', 'wp_password', 'wp_host']).where(deleted_at: nil)
      .each{|row|
        case row.config_key
        when "wp_admin"
          wp_admin = row.string_value
        when "wp_password"
          wp_password = row.string_value
        when "wp_host"          
          wp_host = row.string_value
        end
      }

    @xmlrpc_server = XMLRPC::Client.new2 "http://#{wp_host}/xmlrpc.php"
    @xmlrpc_server.http_header_extra = { 'Content-Type' => 'text/xml' }

    @wp_client = Rubypress::Client.new host: wp_host, username: wp_admin, password: wp_password
  end

  def client
    @wp_client
  end

  def customer_info customer_id
=begin
    {"customer_id"=>"1", "user_login"=>"admin", "user_email"=>"wattaint@gmail.com", 
    "first_name"=>"", "last_name"=>"", "address"=>"", "contactnumber"=>"", 
    "first_name_th"=>"?????", "last_name_th"=>"?????", customer_name=>""}
=end
    @xmlrpc_server.call "cust.show", customer_id.to_s
  end

  def count_total_customer
    total = @xmlrpc_server.call "cust.total"
    total.to_s.to_i
  end
 
  def get_customer_list opts
    #opts = {limit: 10, offset: 1, sort_by: "ID", order: "ASC"}
    @xmlrpc_server.call "cust.list", opts
  end

  def tracking_index opts 
    @xmlrpc_server.call "tracking.index", opts 
  end

  def show_cust_tracking tracking_id
    @xmlrpc_server.call "tracking.show", tracking_id
  end

  def update_cust_tracking tracking_id, opts
    @xmlrpc_server.call "tracking.update", tracking_id, opts
  end  

  def destroy_cust_tracking tracking_id
    @xmlrpc_server.call "tracking.destroy", tracking_id
  end

  def create_cust_tracking opts 
    opts[:no_box]     = opts[:no_box] ? true : false
    opts[:no_repack]  = opts[:no_repack] ? true : false
    
    @xmlrpc_server.call "tracking.create", opts
  end

  def status_desc_update opts 
    if opts.is_a? Hash
      @xmlrpc_server.call "status_desc.update", {
        status_name: (opts[:status_name].nil? ? "" : opts[:status_name]),
        desc_en: (opts[:desc_en].nil? ? "" : opts[:desc_en]),
        desc_th: (opts[:desc_th].nil? ? "" : opts[:desc_th]),
      }
    end
  end
end