class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :owner_id
      t.integer :goal
    
      t.string :fb_page_id
      t.string :fb_page_name
      t.string :fb_page_access_token

      t.timestamps
    end
  end
end
