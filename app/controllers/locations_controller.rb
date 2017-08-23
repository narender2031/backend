class LocationsController < ApplicationController
    def index
        @location = current_team.locations.all
    end
end
