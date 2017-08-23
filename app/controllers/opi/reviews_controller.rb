class Opi::ReviewsController < Opi::OpiController
    before_filter :authenticate

    def index
        if current_team.fb_page_access_token == nil

        else

        end

    end
    def yelp_review

        require 'uri'
        require 'net/http'
        url = URI("https://api.yelp.com/v3/businesses/next-magic-san-francisco/reviews")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request["authorization"] = 'Bearer _9LuWm-x964T1tTrFYjhc1DEqa-nwh9gSn47LnrrbXfabxwy5WbYlXhd0sfQTCv_1PXthAV4OAiR9rsiTGQsKFyzDtF7cgjb_k9TZ86dghrMuYW58eooL0bJ77JwWXYx'

        response = http.request(request)
        puts response.read_body
        res = response.read_body
        data = JSON.parse(res)
        review = data['reviews']
        limit = review.length
        reviews = Array.new
         current_team.reviews.where(src:"https://cdn0.iconfinder.com/data/icons/social-network-24/512/Yelp-16.png").destroy_all
        (0...limit).each do |index|
            details = review[index]
            name = details['user']['name']
            image_url = details['user']['image_url']
            comment= details['text']
            rating= details['rating']
            review_time= details['time_created']
            review = current_team.reviews.new(name: name,
                                                            rating: rating, comment: comment,
                                                            review_time: review_time, src: "https://cdn0.iconfinder.com/data/icons/social-network-24/512/Yelp-16.png")
                        review.save
                        reviews.push<<review
            render json: comment
        end

    end

end
