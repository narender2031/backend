class User < ApplicationRecord
    has_secure_password

    validates_uniqueness_of :email, :phone
    belongs_to :team, optional: true
    
    before_create :generate_access_token
    has_many :reviews
    has_many :invites
 
    private
    def generate_access_token
        begin
            self.token = SecureRandom.hex
        end while self.class.exists?(token: token)
    end
end
