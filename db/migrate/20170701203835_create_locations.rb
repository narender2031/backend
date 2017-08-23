class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.integer :team_id
      t.string :name
      t.string :address
      t.string :phone
      t.string :google_place_id
      t.string :fb_page_name
      t.string :fb_page_id
      t.string :fb_page_access_token
      t.string :yelp_auth_tokan
      t.string :state
      t.string :position
      t.string :website
      t.string :res_id
      t.string :photo
      t.string :link_to_map_url
      t.integer :ratings
      t.string :shortlink
      t.string :yelp_bussiness_id
      t.timestamps
    end
  end
end
