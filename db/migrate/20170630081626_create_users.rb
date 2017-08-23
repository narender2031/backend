class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.integer :team_id
      t.string :token
      t.string :password_digest
      t.string :state
      t.string :password_reset_token
      t.integer  :sign_in_count, default: 0, null: false
      t.string   :confirmation_sent_at
      t.datetime :confirmed_at
      t.string :position
      t.integer :default_location

      t.timestamps
    end
  end
end
