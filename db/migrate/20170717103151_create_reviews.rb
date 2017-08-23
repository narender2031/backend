class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.integer  :location_id
      t.string  :name
      t.string  :comment
      t.integer  :user_id
      t.integer  :team_id
      t.integer  :rating
      t.string  :client_id
      t.string  :src
      t.datetime :review_time
      t.timestamps
    end
  end
end
