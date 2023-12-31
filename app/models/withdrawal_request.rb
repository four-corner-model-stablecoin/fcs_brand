# frozen_string_literal: true

# ステーブルコイン償還リクエストモデル
class WithdrawalRequest < ApplicationRecord
  validates :request_id, presence: true
  validates :amount, presence: true

  belongs_to :stable_coin
  belongs_to :issuer
  belongs_to :acquirer

  enum status: {
    created: 0,
    completed: 1,
    transfering: 2,
    failed: 9
  }
end
