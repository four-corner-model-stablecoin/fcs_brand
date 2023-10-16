class ContractsController < ApplicationController
  protect_from_forgery

  # イシュアとの契約締結
  def agreement_with_issuer
    ActiveRecord::Base.transaction do
      issuer = Issuer.find_or_create_by!(name: params[:name])
      issuer_did = Did.find_or_create_by!(short_form: params[:did], issuer:)
      brand_did = Did.brand

      issuer_pubkey = resolve_did(issuer_did).pubkey
      brand_pubkey =  resolve_did(brand_did).pubkey
      redeem_script = Tapyrus::Script.new << 2 << [issuer_pubkey, brand_pubkey] << 2 << OP_CHECKMULTISIG
      script_pubkey = redeem_script.to_p2sh

      color_identifier = Tapyrus::Color::ColorIdentifier.reissuable(script_pubkey)
      color_id = color_identifier.to_payload.bth

      contracted_at = Time.current
      effect_at = 1.day.after
      expire_at = 3.year.after

      contract = Contract.create!(issuer:, brand_did:, issuer_did:,
                                  script_pubkey: script_pubkey.to_hex,
                                  redeem_script: redeem_script.to_hex,
                                  contracted_at:, effect_at:, expire_at:)

      StableCoin.create!(contract:, color_id:)

      res = {
        color_id:,
        script_pubkey: script_pubkey.to_hex,
        redeem_script: redeem_script.to_hex,
        contracted_at:, effect_at:, expire_at:,
        brand_did: brand_did.short_form
      }

      render json: res
    end
  end

  private

  # @param did Did
  # @return Tapyrus::Key
  def resolve_did(did)
    response = Net::HTTP.get(URI("#{ENV['DID_SERVICE_URI']}/did/resolve/#{did.short_form}"))
    public_key_jwk = JSON.parse(response)['did']['didDocument']['verificationMethod'][0]['publicKeyJwk']
    jwk = JSON::JWK.new(public_key_jwk)

    jwk_to_tapyrus_key(jwk)
  end

  # @param jwk [JSON::JWK] EC secp256k1
  # @return Tapyrus::Key
  def jwk_to_tapyrus_key(jwk)
    key = jwk.to_key

    if key.private_key.nil?
      Tapyrus::Key.new(pubkey: key.public_key.to_bn.to_s(16).downcase.encode('US-ASCII'), key_type: 0)
    else
      Tapyrus::Key.new(priv_key: key.private_key.to_s(16).downcase.encode('US-ASCII'), key_type: 0)
    end
  end
end
