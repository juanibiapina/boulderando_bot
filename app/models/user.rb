class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :telegram_id, presence: true, uniqueness: true
end
