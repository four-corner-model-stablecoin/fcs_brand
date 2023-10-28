# frozen_string_literal: true

class Acquirer < ApplicationRecord
  has_one :account
  has_many :withdrawal_requests
  belongs_to :did
end
