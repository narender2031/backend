class Invite < ApplicationRecord
    belongs_to :user
    belongs_to :location
    belongs_to :team
    validates :name, presence: :true

end
