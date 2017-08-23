class PagesController < ApplicationController
  before_action :authorize
def dash
        @invite = current_team.invites.new
        @location = current_team.locations
        @team = current_team
        if current_user.default_location != nil
            @location_id = Location.find_by_id(current_user.default_location)
            if @location_id == nil
              puts "hello"
              puts current_user.default_location = nil
                current_user.save
                redirect_to settings_path
            else
                @default_location = Location.find(current_user.default_location)

                    if  @default_location.fb_page_access_token != nil
                        fb_page_access_token = @default_location.fb_page_access_token
                        fb_page_id = @default_location.fb_page_id
                        require 'uri'
                        require 'net/http'
                        url = URI("https://graph.facebook.com/"+fb_page_id+"/ratings?access_token="+ fb_page_access_token)
                        http = Net::HTTP.new(url.host, url.port)
                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                        request = Net::HTTP::Get.new(url)
                        response = http.request(request)
                        puts "heelo"+response.read_body
                        @resp = response.read_body
                        res =JSON.parse(@resp)
                        data = res['data']
                        limit = data.length
                        reviews = Array.new
                        @default_location.reviews.where(src: "https://cdn0.iconfinder.com/data/icons/social-network-7/50/3-16.png").destroy_all
                        (0...limit).each do |index|
                            details= data[index]
                            review_time = details['created_time']
                            name =  details['reviewer']['name']
                            client_id = details['reviewer']['id']
                            rating= details['rating']
                            comment = details['review_text']
                            review = current_team.reviews.new(name: name, client_id: client_id,
                                                                rating: rating, comment: comment,
                                                                location_id: @default_location.id,
                                                                review_time: review_time, src: "https://cdn0.iconfinder.com/data/icons/social-network-7/50/3-16.png")
                            review.save
                            reviews.push<<review
                        end
                    end
                    @all_reviews = @default_location.reviews.all
                    @all_invites = @default_location.invites.all
                    @all_invites = @all_invites.sort_by {|obj| obj.created_at }.reverse
                end


            puts @all_invites
        else
            if current_team.locations.empty?
                redirect_to settings_path
            else
                current_user.default_location = current_team.locations.first.id
                current_user.save
                @default_location = Location.find(current_user.default_location)
            if @default_location.fb_page_access_token == nil

            else
                fb_page_access_token = @default_location.fb_page_access_token
                fb_page_id = @default_location.fb_page_id
                require 'uri'
                    require 'net/http'
                    url = URI("https://graph.facebook.com/"+fb_page_id+"/ratings?access_token="+ fb_page_access_token)
                    http = Net::HTTP.new(url.host, url.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    request = Net::HTTP::Get.new(url)
                    response = http.request(request)
                    puts "heelo"+response.read_body
                    @resp = response.read_body
                    res =JSON.parse(@resp)
                    data = res['data']
                    limit = data.length
                    reviews = Array.new
                    @default_location.reviews.where(src: "https://cdn0.iconfinder.com/data/icons/social-network-7/50/3-16.png").destroy_all
                    (0...limit).each do |index|
                        details= data[index]
                        review_time = details['created_time']
                        name =  details['reviewer']['name']
                        client_id = details['reviewer']['id']
                        rating= details['rating']
                        comment = details['review_text']
                        review = current_team.reviews.new(name: name, client_id: client_id,
                                                            rating: rating, comment: comment,
                                                            location_id: @default_location.id,
                                                            review_time: review_time, src: "https://cdn0.iconfinder.com/data/icons/social-network-7/50/3-16.png")
                        review.save
                        reviews.push<<review
                end

                @all_reviews = @default_location.reviews.all
                @all_invites = @default_location.invites.all
                @all_invites = @all_invites.sort_by {|obj| obj.created_at }.reverse
            end
            end
        end

end

    private

        def invite_params
            params.require(:invite).permit(:name, :phone)
        end
    end
