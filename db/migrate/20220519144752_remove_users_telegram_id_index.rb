# frozen_string_literal: true

class RemoveUsersTelegramIdIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :telegram_id, unique: true
  end
end
