class Opi::LocationsController < Opi::OpiController
    before_filter :authenticate
    def index
        render json: current_team.locations
    end

    def create
        @location = current_team.locations.new(location_params)
        if @location.save
           render status: 200,json: @location
        else
            render status: 422, json:  {errors:
                @location.errors
            }
        end

    end

    def set_location
        current_user.default_location = params[:location_id]
        if current_user.save
                render json: {"msg": "Success"}
        else
            render json: {"msg": "Something went wrong"}

        end
    end


    def facebook
       @location = current_team.locations.find(params[:location_id])
       @location.fb_page_name =  params[:fb_page_name]
       @location.fb_page_id = params[:fb_page_id]
       @location.fb_page_access_token = params[:fb_page_access_token]
       @location.link_to_map_url = params[:link_to_map_url]
       puts params[:link_to_map_url]
       fb_page_access_token = params[:fb_page_access_token]
        require 'uri'
        require 'net/http'
        url = URI("https://graph.facebook.com/v2.8/oauth/access_token?grant_type=fb_exchange_token&client_id=228343344341844&client_secret=967b93f9dceb6d91d59795a83ee80503&fb_exchange_token="+ fb_page_access_token)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        response = http.request(request)

        @location.fb_page_access_token = JSON.parse(response.body)['access_token']
        puts JSON.parse(response.body)['access_token']
        if @location.save
            render json: {"msg": "Success"}
        else
            render json: {"msg": "Something went wrong"}
        end

    end


    private
    def location_params
        params.require(:location).permit(:id, :name, :address, :phone,
         :google_place_id, :fb_page_name, :fb_page_id, :fb_page_access_token, :link_to_map_url)
    end




end
