class SessionsController < ApplicationController
    def new
    end

    def create
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            cookies[:token] = user.token
            redirect_to root_url
        else
            flash.now.alert = "Email or password is invalid"
            render :new
        end
    end

    def destroy
            session[:user_id] = nil
            cookies[:token] = nil
            render :new
    end
end        