class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.string :name
      t.string :last_name
      t.string :birthday
      t.string :address
      t.string :postal_code
      t.string :city
      t.string :phone_number
      t.string :email
      t.string :usc_number

      t.timestamps
    end
  end
end
