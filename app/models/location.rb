class Location < ApplicationRecord
   belongs_to :team
   has_many :reviews
   has_many :invites
   
end
