class Did < ApplicationRecord
  has_one :key
  has_many :contract_as_brand, class_name: 'Contract', foreign_key: 'brand_did_id'
  has_many :contract_as_issuer, class_name: 'Contract', foreign_key: 'issuer_did_id'

  belongs_to :issuer, optional: true

  validates :short_form, presence: true

  def self.brand
    brand_did = Did.find_or_create_by!(short_form: ENV['BRAND_DID'])
    brand_key = Key.find_or_create_by!(jwk: ENV['BRAND_DID_JWK'], did: brand_did)
    brand_did
  end
end
