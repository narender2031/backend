class Opi::AuthController < Opi::OpiController
    before_filter :authenticate
    ## before_action :set_user, only: [:facebook]
    
    def index
        render json: current_user
    end
    
    def facebook
        puts "hello"
        @team = @current_user.team
        @team.fb_page_name = params[:fb_page_name]
        @team.fb_page_id = params[:fb_page_id]
         
        fb_page_access_token = params[:fb_page_access_token]
        require 'uri'
        require 'net/http'
        url = URI("https://graph.facebook.com/v2.8/oauth/access_token?grant_type=fb_exchange_token&client_id=228343344341844&client_secret=967b93f9dceb6d91d59795a83ee80503&fb_exchange_token="+ fb_page_access_token)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        response = http.request(request)
       
        @team.fb_page_access_token = JSON.parse(response.body)['access_token']
        puts JSON.parse(response.body)['access_token']
        if @team.save
            render json: {"msg": "Success"}
        else 
            render json: {"msg": "Something went wrong"}
        end
       
    end


end