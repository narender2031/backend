class CreateInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :invites do |t|
      t.string :name
      t.string :phone
      t.string :state
      t.integer :user_id
      t.integer :location_id
      t.integer :team_id
      t.timestamps
    end
  end
end
