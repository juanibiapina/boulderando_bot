class AddBirthdayDateToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :birthday_date, :date
  end
end
