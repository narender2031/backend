module Opi
  class OpiController < ApplicationController
    skip_before_filter :verify_authenticity_token
    protect_from_forgery with: :null_session
    
    def current_user
      @current_user
    end

    def authenticate
        authenticate_or_request_with_http_token do |token, options|
            User.exists?(token: token)
            if User.exists?(token: token)
                @current_user = User.find_by(token: token)
            end
        end
    end
    
  end
end