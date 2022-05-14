# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :sessions do |t|
      t.string :gym_name
      t.date :date
      t.string :time
      t.belongs_to :user, null: false, foreign_key: true

      t.index [:gym_name, :date, :time]

      t.timestamps
    end
  end
end
