require 'grape-swagger'
module Invites
    class Data < Grape::API
        default_format :json

        helpers do
            def authenticate
                token = headers['Authorization']
                ##puts token
                User.exists?(token: token)
                if User.exists?(token: token)
                    @current_user = User.find_by(token: token)

                else
                    error! 'Unauthorized', 401
                end
            end
            def current_user
                @current_user
            end
            def invites
                current_user.invites.all
            end
            def default_location
                @default_location = Location.find(current_user.default_location)
            end
            def current_team
                @current_team = current_user.team if current_user
            end

        end

        resource :signup_form do
          desc "Signup"

            params do
              requires :team_name, type:String, documentation: { in: 'body' }
              requires :team_goal, type:Integer
              requires :first_name, type:String
              requires :last_name, type:String
              requires :email, type:String
              requires :password, type:String
              requires :state, type:String
              requires :phone, type:String

            end
            post '/signup' do
                if params[:team_name].blank?
                  error!({error:"parameter are missing"},401)
                end
                if params[:team_goal].blank?
                  error!({error:"parameter are missing "},401)
                end
                if Team.exists?(name: params[:team_name])
                  error!({error:"Team is registered already"},401)
                end

                if User.exists?(email: params[:email])
                  error!({error:"email is registered already"},400)
                end
                if User.exists?(phone: params[:phone])
                  error!({error: "phone is already register"},400)
                end
              if params[:email].include?("@")

                Team.create!({
                    name:params[:team_name],
                    goal:params[:team_goal]
                  })
                  if params[:email].blank?
                    error!({error:"parameter are missing"},401)
                  end
                  if params[:first_name].blank?
                    error!({error:"parameter are missing"},401)
                  end
                  if params[:last_name].blank?
                    error!({error:"parameter are missing"},401)
                  end
                  if params[:phone].blank?
                    error!({error:"parameter are missing"},401)
                  end
                  if params[:state].blank?
                    error!({error:"parameter are missing"},401)
                  end

                  User.create!({
                    team_id:Team.last.id,
                    first_name:params[:first_name],
                    last_name:params[:last_name],
                    email:params[:email],
                    password:params[:password],
                    phone:params[:phone],
                    state:params[:state]
                    })
                    ({token:User.last.token})
                else
                  error!({error:"invalid email address"},401)
                end

            end
        end
        resource :invites do
            desc "List all invites according to location",{
            headers: {
                "Authorization" => {
                description: "Valdates your identity",
                required: true
                }
            }
            }
            get '/all_invites' do
                authenticate
                status 200
                @invite = current_user.invites.all
                @invite.all
                if status == 200
                    @invite.all

                else
                     error!({ error: 'message is not sent', detail: 'something went wrong' }, 400)
                end
            end

            desc "create a new invites",{
            headers: {
                "Authorization" => {
                description: "Valdates your identity",
                required: true
                }
            }
            }
            params do
                requires :name, type:String, documentation: { in: 'body' }
                requires :phone, type:String
            end
            post '/create' do

                authenticate
                status 201

                    if params[:name].blank?
                       error!({message: "parameter are missing"},400)
                    end
                    if  params[:phone].blank?
                      puts "name"
                        error!({message: "parameter are missing"},400)
                    end
                    if params[:name]== "string" && params[:phone] == "string"
                      puts "String error"
                      error!({message:"error"},404)
                    end
                    if current_user.default_location != nil
                      puts params[:phone]
                        require 'uri'
                            require 'net/http'

                            url = URI("http://control.msg91.com/api/v2/sendsms")
                            body =  { sender: "Levler",
                                    route: "4",
                                    country: "91",
                                    sms: [{
                                        "message": "Hi, " + params[:name] + "! Thank you for choosing "+default_location.name+". Can you take 30 seconds and leave us a quick review? This link below makes it easy: "+default_location.shortlink,
                                        "to": [params[:phone]]
                                    }]}
                            puts params[:name]
                            http = Net::HTTP.new(url.host, url.port)
                            request = Net::HTTP::Post.new(url)
                            request["content-type"] = 'application/json'
                            request["authkey"] = '163832A12h4EhY595bd799'
                            request.body = body.to_json
                            response = http.request(request)
                            ({message:response})
                            puts response.body
                            puts response.code
                            @resp = response.body
                            if response.code == "200"

                                current_user.invites.create!({
                                    name:params[:name],
                                    phone:params[:phone],
                                    location_id:current_user.default_location
                                })


                             ({message:"success"})

                            else
                                error!({ error: 'message is not sent', detail: 'something went wrong' }, 401)
                            end

                    else
                      error!({message:"please select the location first"})
                    end
            end

            desc "delete an invites",{
            headers: {
                "Authorization" => {
                description: "Valdates your identity",
                required: true
                }
            }
            }
            params do
                requires :id, type:Integer, documentation: { in: 'query' }
            end

            delete ':id' do
                authenticate
                status 201
                @current_invite = current_user.invites.find_by_id(params[:id])
                if @current_invite == nil
                    error!({message: "invalid invite id"},400)
                end

                if invites.find(params[:id]).destroy!
                    ({message:"successfuly delete"})
                else
                     error!({ error: 'message is not delete', detail: 'something went wrong' }, 401)
                end
            end

            desc "update an invites",{
            headers: {
                "Authorization" => {
                description: "Valdates your identity",
                required: true
                }
            }
            }
            params do
                requires :id, type:Integer, documentation: { in: 'query' }
                requires :name, type:String, documentation: { in: 'body' }
                requires :phone, type:String
            end
            put ':id' do
                authenticate
                status 200

                if params[:name].blank?
                   error!({message: "parameter are missing"},400)
                end
                if  params[:phone].blank?
                  puts "name"
                    error!({message: "parameter are missing"},400)
                end
                if params[:name]== "string" && params[:phone] == "string"
                  puts "String error"
                  error!({message:"Data is missing"},404)
                end
                @current_invite = current_user.invites.find_by_id(params[:id])
                if @current_invite == nil
                    error!({message: "invalid invite id"})
                end
                if params[:name] && params[:phone] != nil
                invites.find(params[:id]).update({
                    name:params[:name],
                    phone:params[:phone]
                })



                    ({ code: 200, message: 'a changed status code' })
                else
                     error!({ error: 'message is not update', detail: 'something went wrong' }, 401)
                end
            end
        end

        resource :auth do

            desc "Creates and returns access_token if valid login"
                params do
                    requires :login, type: String, documentation: { in: 'body' }, desc: "Username or email address"
                    requires :password, type: String, desc: "Password"
                end
                post '/login' do
                    if params[:login].include?("@")
                        user = User.find_by_email(params[:login].downcase)
                    else
                        error!('Unauthorized', 404)
                    end

                    if user && user.authenticate(params[:password])
                        ({"token": user.token})
                    else
                    error!('Unauthorized', 401)
                    end
                end
        end

        resource :locations do
            desc "List of all locations",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }
                get '/all_locations' do
                    authenticate
                    status 200
                    @location = current_team.locations.all
                    @location.all
                    if status == 200
                        @location.all
                    else
                        error!({ error: 'message is not sent', detail: 'something went wrong' }, 401)
                    end
                end


            desc "delete location",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }
                params do
                    requires :id, type:Integer, documentation: { in: 'query' }
                end
                delete ':id' do
                    authenticate
                    if params[:id] != current_user.default_location
                        error!({error:"invalid location id"})

                    end
                    if Location.find(params[:id]).destroy!
                         ({message:"success"})


                    else
                        error!({error:"location is not deleted"},401)
                    end

                end

            desc "update in location",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }
                params do
                    requires :id, type:Integer, documentation: { in: 'query' }
                    requires :name, type:String, documentation: { in: 'body' }
                    requires :google_place_id, type:String
                    requires :address, type:String
                    requires :phone, type:String
                    requires :photo, type:String
                    requires :link_to_map_url, type:String
                    requires :ratings, type:Integer
                    requires :shortlink, type:String
                    requires :website, type:String
                end
                put ':id' do
                    authenticate
                    status 200
                    if params[:id] != current_user.default_location
                        error!({error:"invalid location id"},401)
                    end
                    current_team.locations.find(params[:id]).update({
                        name:params[:name],
                        phone:params[:phone],
                        address:params[:address],
                        google_place_id:params[:google_place_id],
                        photo:params[:photo],
                        link_to_map_url:params[:link_to_map_url],
                        ratings:params[:ratings],
                        shortlink:params[:shortlink],
                        website:params[:website]
                    })
                    if status == 200
                        ({
                            "message":"success"
                        })
                    else
                        error!({error:"location is not deleted"},401)
                    end
                end
            end


        resource :reviews do
            desc "List of all review according to location",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }

                get do
                    authenticate
                    if current_user.default_location == nil
                      error!({error:"Select the location first"},401)
                    end
                    if default_location.fb_page_access_token == nil
                      error!({message:"Select the facebook Page"},401)
                    end
                    fb_page_id = default_location.fb_page_id;
                    fb_page_access_token = default_location.fb_page_access_token;

                        if fb_page_id.blank?
                           error!({message: "parameter are missing"},400)
                        end
                        if  fb_page_access_token.blank?

                            error!({message: "parameter are missing"},400)
                        end
                        require 'uri'
                        require 'net/http'
                        url = URI("https://graph.facebook.com/"+fb_page_id+"/ratings?access_token="+fb_page_access_token)
                        http = Net::HTTP.new(url.host, url.port)
                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                        request = Net::HTTP::Get.new(url)
                        response = http.request(request)
                        if response.code == "400"
                          error!({error:"Enter the valid page id and Auth tookan"},400)
                        end
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
                                                                location_id: default_location.id,
                                                                review_time: review_time, src: "https://cdn0.iconfinder.com/data/icons/social-network-7/50/3-16.png")
                            review.save
                            reviews.push<<review

                          end

                    ({message:"Success"})


                end
            end

        resource :create_locations do
            desc "get the location details by google place id",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }
                params do
                    requires :google_place_id, type:String, documentation: { in: 'query' }
                end
                route_param :google_place_id do
                    get '/glocations' do
                        authenticate
                        status 200
                        require 'uri'
                        require 'net/http'

                        url = URI("https://maps.googleapis.com/maps/api/place/details/json?placeid="+params[:google_place_id]+"&key=AIzaSyC0EjDVAmepMXaGKMZ3E4oVtZ-mAAoXMyU")

                        http = Net::HTTP.new(url.host, url.port)
                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

                        request = Net::HTTP::Get.new(url)
                        response = http.request(request)
                        data = JSON.parse(response.read_body)
                        ({response:response.body})
                        if data["status"] == "INVALID_REQUEST"
                            error!({error:"invalid place_id"}, 401)
                        else
                            name  = data["result"]["name"]
                            google_place_id = data["result"]["place_id"]
                            address = data["result"]["formatted_address"]
                            phone = data["result"]["international_phone_number"]
                            rating = data["result"]["rating"]
                            reviews=data["result"]["reviews"]

                                current_team.locations.create!({
                                name:name,
                                team_id:current_team.id,
                                address:address,
                                phone:phone,
                                ratings:rating,
                                    google_place_id:google_place_id
                                })
                                if status == 200
                                    ({response:"success"})
                                else
                                    error!({error:"location is not stored"},401)
                                end
                        end

                    end
                end
            end
        resource :google_reviews do
            desc "get the google reviews by google place id ",{
                headers: {
                    "Authorization" => {
                    description: "Valdates your identity",
                    required: true
                    }
                }
                }
                params do
                    requires :google_place_id, type:String
                    requires :location_id, type:Integer, documentation: { in: 'body' }
                end
                route_param :google_place_id  do
                    post '/reviews' do
                        authenticate
                        status 201
                        require 'uri'
                        require 'net/http'

                        url = URI("https://maps.googleapis.com/maps/api/place/details/json?placeid="+params[:google_place_id]+"&key=AIzaSyC0EjDVAmepMXaGKMZ3E4oVtZ-mAAoXMyU")
                        http = Net::HTTP.new(url.host, url.port)
                        http.use_ssl = true
                        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                        request = Net::HTTP::Get.new(url)
                        response = http.request(request)
                        data = JSON.parse(response.read_body)

                        if params[:location_id]!= current_user.default_location
                            error!({message:"INvalid location id"}, 401)
                        end
                        if data["status"]== "INVALID_REQUEST"
                            error!({message:"invalid place id"}, 401)
                        else
                            reviews =data["result"]["reviews"]
                            puts reviews

                            limit =  reviews.length
                            array = Array.new
                          default_location.reviews.where(src:"https://cdn1.iconfinder.com/data/icons/social-networks-15/512/gogle_network_logo-16.png").destroy_all
                        (0...limit).each do |index|
                            details= reviews[index]
                            name =  details['author_name']
                            review_time = details['time']
                            rating= details['rating']
                            comment = details['text']
                            review = default_location.reviews.new(name: name,
                                                                rating: rating, comment: comment,
                                                                location_id: params[:location_id],
                                                                review_time: review_time, src: "https://cdn1.iconfinder.com/data/icons/social-networks-15/512/gogle_network_logo-16.png")
                            review.save
                            array.push<<review
                        end
                        if response.code == "200"
                            ({response: "success"})
                        else
                            error!(message:"something went wrong")
                        end
                        end
                    end
                end

        end
        resource 'review_link' do
          desc "create a shortlink for google reviewes ",{
              headers: {
                  "Authorization" => {
                  description: "Valdates your identity",
                  required: true
                  }
              }
              }
          params do
            requires :google_place_id, type:String, documentation: {in:'body'}
          end
          post '/shortlink' do
            authenticate
            require 'uri'
            require 'net/http'
            if params[:google_place_id]=="string"
              error!({message:"Invalid perameter"},404)
            end
            if params[:google_place_id].blank?
              error!({message:"perameter are missing"},401)
            end


            url = URI("https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyB9ti0A6n6dzMteVS_Td4n_SxdloP8IT_A")

            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Post.new(url)
            request["content-type"] = 'application/json'
            request.body = "{\"longUrl\": \"https://search.google.com/local/writereview?placeid="+params[:google_place_id]+"\"}"
              ({response:http.request(request)})
            response = http.request(request)

            puts response.read_body
            result = JSON.parse(response.body)
            shortlink = result["id"]
            if response.code == "200"
              @location=Location.find(default_location)
              @location.shortlink=shortlink
              @location.save
                ({message: "location is saved"})
            else
                error!({message:"review shortlink is not saved"},404)
            end
          end
        end

      resource 'yelp' do
          desc "get the review from yelp",{
              headers: {
                  "Authorization" => {
                  description: "Valdates your identity",
                  required: true
                  }
              }
              }
          params do
            requires :yelp_bussiness_id, type:String
          end
        route_param :yelp_bussiness_id  do
          get '/yelp_reviews' do
            authenticate
            if current_user.default_location == nil
              error!({message:"Select the location first"},404)
            else
            @yelp = Location.find(current_user.default_location)
            end
            if @yelp.yelp_auth_tokan == nil
              error!({message:"Get the authentation tookan first"},404)
            end
            require 'uri'
            require 'net/http'
            url = URI("https://api.yelp.com/v3/businesses/"+params[:yelp_bussiness_id]+"/reviews")
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            request = Net::HTTP::Get.new(url)
            request["authorization"] = @yelp.yelp_auth_tokan
            response = http.request(request)
            res = response.read_body
            data = JSON.parse(res)
            puts response.code
            if response.code == "404"
              error!({message:"BUSSINESS NOT FOUND"},404)
            end
            if response.code =="401"
              error!({message:"INVALID AUTHKEY"},401)
            end
            array= Array.new
            result = data["reviews"]
            limit= result.length
            default_location.reviews.where(src:"https://cdn0.iconfinder.com/data/icons/social-network-24/512/Yelp-16.png").destroy_all
            (0...limit).each do |index|
              details= result[index]
              name = details["user"]["name"]
              comment = details["text"]
              rating = details["rating"]
              review_time = details["time_created"]
              review = default_location.reviews.new(
                                    name: name,
                                    comment: comment,
                                    rating: rating,
                                    review_time: review_time,
                                    src: "https://cdn0.iconfinder.com/data/icons/social-network-24/512/Yelp-16.png"
                                        )
                    review.save
                    array.push << review

            end
            ({message:"success"})

          end
        end
      end

      resource "yelp_auth_tokan" do
        desc "authenticate yelp api",{
            headers: {
                "Authorization" => {
                description: "Valdates your identity",
                required: true
                }
            }
            }
            params do
              requires :client_id, type:String, documentation: {in: 'body'}
              requires :client_secret, type:String
            end
            post "/yelp_auth" do
              authenticate
              if params[:client_id]=="string"
                error!({message:"Invalid perameter"},404)
              end
              if params[:client_secret]=="string"
                error!({message:"Invalid perameter"},404)
              end
              if params[:client_id].blank?
                error!({message:"perameter are missing"},401)
              end
              if params[:client_secret].blank?
                error!({message:"perameter are missing"},401)
              end
              puts "client_id="+params[:client_id]+"&client_secret='"+params[:client_secret]+"'"
              require 'uri'
              require 'net/http'
              url = URI("https://api.yelp.com/oauth2/token")
              http = Net::HTTP.new(url.host, url.port)
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_NONE
              request = Net::HTTP::Post.new(url)
              request["content-type"] = 'application/x-www-form-urlencoded'
              request.body = "client_id="+params[:client_id]+"&client_secret="+params[:client_secret]+""
              response = http.request(request)
              puts response.read_body
              result = JSON.parse(response.body)
              if response.code=="400"
                error!({error:"Invalif parameter"})
              end
              access_token = result["access_token"]
              token_type = result["token_type"]
              yelp_auth_tokan = token_type+" "+access_token
              puts yelp_auth_tokan
                if current_user.default_location == nil
                    error!({message:"Select the location first"},404)
                  else
                  @location = Location.find(current_user.default_location)
                  @location.yelp_auth_tokan = yelp_auth_tokan
                  @location.save
                  ({message:yelp_auth_tokan})
               end
            end
          end


            resource 'zomato' do
              desc "zomoto reviews",{
                  headers: {
                      "Authorization" => {
                      description: "Valdates your identity",
                      required: true
                      }
                  }
                  }
            params do
              requires :user_key, type:String, documentation: {in: 'query'}
            end
                get '/zomato_reviews' do
                  authenticate
                  if current_user.default_location == nil
                    error!({message:"Select the location first"},404)
                  else
                    @loc = Location.find(current_user.default_location)
                  end
                  if @loc.res_id == nil
                    error!({error:"Get the res_id First"},401)
                  end
                  require 'uri'
                    require 'net/http'
                    url = URI("https://developers.zomato.com/api/v2.1/reviews?res_id="+@loc.res_id+"")
                    http = Net::HTTP.new(url.host, url.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    request = Net::HTTP::Get.new(url)
                    request["user-key"] =params[:user_key]
                    response = http.request(request)
                    puts response.read_body
                    if  response.code =="403"
                      error!({error:"Invalid User-key"},403)
                    end
                    result = JSON.parse(response.body)
                    if result["reviews_count"]== 0
                      error!({error:"No review FOUND]"})
                    end

                    data = result["user_reviews"]
                    array = Array.new
                    limit = data.length
                    default_location.reviews.where(src:"https://cdn2.iconfinder.com/data/icons/essential-circles-1/24/_z-16.png").destroy_all
                    (0...limit).each do |index|
                      details = data[index]
                      comment = details["review"]["review_text"]
                      name = details["review"]["user"]["name"]
                      review_time = details["review"]["timestamp"]
                      rating = details["review"]["rating"]
                      review = default_location.reviews.new(name: name,
                                                            comment: comment,
                                                            review_time: review_time,
                                                            rating: rating,
                                                            src: "https://cdn2.iconfinder.com/data/icons/essential-circles-1/24/_z-16.png")
                      review.save
                      array.push << review
                    end
                    ({message:"success"})


              end
            end

            resource "zomato_id" do
              desc "get the res id",{
                  headers: {
                      "Authorization" => {
                      description: "Valdates your identity",
                      required: true
                      }
                  }
                  }
                  params do
                    requires :latitude, type:String, documentation: {in: 'query'}
                    requires :longitude, type:String
                    requires :user_key, type:String
                    requires :name, type:String
                  end
                  get '/res_id' do
                    authenticate
                    if current_user.default_location == nil
                      error!({message:"Select the location first"},404)
                    end
                    require 'uri'
                    require 'net/http'

                    url = URI("https://developers.zomato.com/api/v2.1/geocode?lat="+params[:latitude]+"&lon="+params[:longitude]+"")

                    http = Net::HTTP.new(url.host, url.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

                    request = Net::HTTP::Get.new(url)
                    request["user-key"] = params[:user_key]
                    response = http.request(request)
                    puts response.read_body
                    result = JSON.parse(response.body)
                    data = result["nearby_restaurants"]
                    limit = data.length
                    (0...limit).each do |index|
                      details = data[index]
                      name = details["restaurant"]["name"]
                      if name == params[:name]
                        @res_id = details["restaurant"]["R"]["res_id"]
                        @res_location = Location.find(current_user.default_location)
                        @res_location.res_id = @res_id
                        @res_location.save
                        puts @res_id
                      end
                    end
                    if @res_id!= nil
                          ({message:@res_id})
                    else
                      error!({error:"restaurant is not founded"},401)
                    end
                  end

            end


            resource "vevsa_invites" do
              desc "create a new invites",{
              headers: {
                  "Authorization" => {
                  description: "Valdates your identity",
                  required: true
                  }
              }
              }
              params do
                  requires :name, type:String, documentation: { in: 'body' }
                  requires :phone, type:String
                  requires :message, type:String
                  requires :package_name, type:String

              end
              post '/create_invite' do

                  authenticate
                  status 201
                  require 'uri'
                  require 'net/http'


                  url = URI("https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyB9ti0A6n6dzMteVS_Td4n_SxdloP8IT_A")

                  http = Net::HTTP.new(url.host, url.port)
                  http.use_ssl = true
                  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

                  request = Net::HTTP::Post.new(url)
                  request["content-type"] = 'application/json'
                  request.body = "{\"longUrl\": \"http://play.google.com/store/apps/details?id="+params[:package_name]+"\"}"
                    ({response:http.request(request)})
                  response = http.request(request)

                  puts response.read_body
                  result = JSON.parse(response.body)
                  @shortlink = result["id"]

                      if params[:name].blank?
                         error!({message: "parameter are missing"},400)
                      end
                      if  params[:phone].blank?
                        puts "name"
                          error!({message: "parameter are missing"},400)
                      end
                      if params[:name]== "string" && params[:phone] == "string"
                        puts "String error"
                        error!({message:"error"},404)
                      end
                      if current_user.default_location != nil
                        puts params[:phone]
                          require 'uri'
                              require 'net/http'

                              url = URI("http://control.msg91.com/api/v2/sendsms")
                              body =  { sender: "Levler",
                                      route: "4",
                                      country: "91",
                                      sms: [{
                                          "message": params[:message] +" "+@shortlink,
                                          "to": [params[:phone]]
                                      }]}
                              puts params[:name]
                              http = Net::HTTP.new(url.host, url.port)
                              request = Net::HTTP::Post.new(url)
                              request["content-type"] = 'application/json'
                              request["authkey"] = '163832A12h4EhY595bd799'
                              request.body = body.to_json
                              response = http.request(request)
                              ({message:response})
                              puts response.body
                              puts response.code
                              @resp = response.body
                              if response.code == "200"

                                  current_user.invites.create!({
                                      name:params[:name],
                                      phone:params[:phone],
                                      location_id:current_user.default_location
                                  })


                               ({message:"success"})

                              else
                                  error!({ error: 'message is not sent', detail: 'something went wrong' }, 401)
                              end

                      else
                        error!({message:"please select the location first"})
                      end
              end
            end


    add_swagger_documentation version: 'v1'
    end
end
