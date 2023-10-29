# frozen_string_literal: true

class StableCoin < ApplicationRecord
  has_many :withdrawal_requests
  belongs_to :contract

  validates :color_id, presence: true
end
