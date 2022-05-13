# frozen_string_literal: true

class RenameUsersBirthdayColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :birthday, :string
    rename_column :users, :birthday_date, :birthday
  end
end
