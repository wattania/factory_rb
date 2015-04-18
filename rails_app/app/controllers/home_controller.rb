class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index 
    user = current_user 
    @firstname  = user.first_name
    @lastname   = user.last_name
    @is_admin   = user.is_admin
    @username   = user.user_name

    @manifests = {}
    if Rails.env == 'production'
      path = Rails.root.join 'public', 'assets', 'manifest-*.json'
      Dir.glob(path) { |file|  
        File.open file, 'r' do |f|
          manifests = JSON.parse f.read
          (manifests["files"] || {}).each{|k, v|
            @manifests[v["logical_path"]] = k
          }
        end
      }
    end
  end

  def app_init
    render json: { a: 1}
  end
end
