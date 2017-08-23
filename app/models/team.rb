class Team < ApplicationRecord

    has_many :users
    has_many :invites, through: :users
    has_many :locations
    has_many :reviews  
    accepts_nested_attributes_for :locations, :reject_if => :all_blank, :allow_destroy => true

    accepts_nested_attributes_for :users

end
