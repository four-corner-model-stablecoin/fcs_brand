class StableCoin < ApplicationRecord
  belongs_to :contract

  validates :color_id, presence: true
end
