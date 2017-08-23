class ReviewsController < ApplicationController
    def index
        @all_reviews = current_team.reviews
        
    end

end
