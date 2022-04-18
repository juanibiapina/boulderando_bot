class AddIndexToUsersTelegramId < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :telegram_id
  end
end
