# frozen_string_literal: true
class RemoveAddressFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :address, :string
    remove_column :users, :postal_code, :string
    remove_column :users, :city, :string
  end
end
