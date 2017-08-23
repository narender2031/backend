class TeamsController < ApplicationController
    before_filter :authorize

    def edit
        @team = current_user.team
        @location = current_team.locations
    end

  

    def update
        @team = Team.find(params[:id])
        if @team.update(team_params)
            redirect_to settings_path
        else
            render :edit 
        end
    end
    
    private 
    def team_params
        params.require(:team).permit(:name,
            locations_attributes: [:id, :name, :address, :phone, :google_place_id, :website, :photo, :link_to_map_url, :ratings, :shortlink])
    end
end
