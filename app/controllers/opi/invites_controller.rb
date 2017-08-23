class Opi::InvitesController < Opi::OpiController
    before_filter :authenticate
   
    def index
         render json: current_user.invites
    end
    
    def create
            @invite = current_user.invites.new(invite_params)
            @default_location = Location.find(current_user.default_location)
                require 'uri'
                require 'net/http'
            
            if @default_location
                url = URI("http://control.msg91.com/api/v2/sendsms")
                body =  { sender: "Levler", 
                        route: "4",
                        country: "91",
                        sms: [{
                            "message": "Hi," + @invite.name + "! Thank you for choosing" + @default_location.name + ". Can you take 30 secounds and leave us a quick review? This link below make it easy:" + @default_location.shortlink,
                            "to": [@invite.phone]
                        }] }
                http = Net::HTTP.new(url.host, url.port)
                request = Net::HTTP::Post.new(url)
                request["content-type"] = 'application/json'
                request["authkey"] = '163832A12h4EhY595bd799'
                request.body = body.to_json
                response = http.request(request)
                @resp = response.body
                @res=response.code
                    @invite.save
                    if @res == "200"
                       
                            render status: 200, json: {Success:{message:"your invitation is send ", short_message: "send"}}
                        
                    else
                        render status: 422, json: {error:{message: "your invite is not send ", short_message: "Something Wrong"} }   
                   
                    end
            end 
                     
    end


        private

        def invite_params
            params.require(:invite).permit(:name, :phone, :sender, :route, :country, :sms)
        end


end    