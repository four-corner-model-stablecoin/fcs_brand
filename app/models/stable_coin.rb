# frozen_string_literal: true

# ステーブルコインモデル
# ブランドないを流通するステーブルコイン全てに対し作成される
class StableCoin < ApplicationRecord
  has_many :withdrawal_requests
  belongs_to :contract

  validates :color_id, presence: true
end
