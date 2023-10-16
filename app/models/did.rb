class Did < ApplicationRecord
  has_many :contract_as_brand, class_name: 'Contract', foreign_key: 'brand_did_id'
  has_many :contract_as_issuer, class_name: 'Contract', foreign_key: 'issuer_did_id'

  belongs_to :issuer

  validates :short_form, presence: true
end
