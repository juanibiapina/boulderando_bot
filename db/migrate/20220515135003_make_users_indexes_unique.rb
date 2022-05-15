# frozen_string_literal: true

class MakeUsersIndexesUnique < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :email
    remove_index :users, :telegram_id
    add_index :users, :telegram_id, unique: true
    add_index :users, :email, unique: true
  end
end
