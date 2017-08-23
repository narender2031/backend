class AnalyticsController < ApplicationController
    def index
        if current_user.default_location == nil
           
        else
            @default_location = Location.find(current_user.default_location)
            @location = current_team.locations.all
        end    
    end
end
