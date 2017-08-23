class InvitesController < ApplicationController
    before_filter :authorize

    def index
            @invite = current_user.invites.new
            @all_invites= current_team.invites.all
            @all_invites = @all_invites.sort_by {|obj| obj.created_at }.reverse

    end

      def create
            respond_to do |format|
            @invite = current_user.invites.new(invite_params)
            @default_location = Location.find(current_user.default_location)
            if current_user.default_location != nil
                @invite.location_id = current_user.default_location
            end
            if @default_location
                require 'uri'
                require 'net/http'

                url = URI("http://control.msg91.com/api/v2/sendsms")
                body =  { sender: "Levler",
                        route: "4",
                        country: "91",
                        sms: [{
                            "message": "Hi, " + @invite.name + "! Thank you for choosing " +  @default_location.name + ". Can you take 30 seconds and leave us a quick review? This link below makes it easy: " +  @default_location.shortlink,
                            "to": [@invite.phone]
                        }]}
                http = Net::HTTP.new(url.host, url.port)
                request = Net::HTTP::Post.new(url)
                request["content-type"] = 'application/json'
                request["authkey"] = '163832A12h4EhY595bd799'
                request.body = body.to_json
                response = http.request(request)
                puts response.body
                puts response.code
                @resp = response.body
                @invite.save
                format.js
                format.html { redirect_to root_path, notice: "Invites send" }
            end
        end
    end
        private
        def invite_params
            params.require(:invite).permit(:name, :phone)
        end




end
