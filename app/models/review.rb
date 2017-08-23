class Review < ApplicationRecord
    belongs_to :user
    belongs_to :location
    belongs_to :team
end
