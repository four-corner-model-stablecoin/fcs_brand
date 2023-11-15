# frozen_string_literal: true

# アクワイアラモデル
class Acquirer < ApplicationRecord
  has_one :account
  has_many :withdrawal_requests
  belongs_to :did

  after_create do
    self.build_account.save!
  end
end
