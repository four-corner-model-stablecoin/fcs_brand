# frozen_string_literal: true

module Api
  class ContractsController < ApplicationController
    protect_from_forgery

    # イシュアとの契約締結
    def agreement_with_issuer
      ActiveRecord::Base.transaction do
        issuer_did = Did.find_or_create_by!(short_form: params[:did])
        issuer = Issuer.find_or_create_by!(name: params[:name], did: issuer_did)
        brand_did = Did.first

        # DID から公開鍵を取り出す
        issuer_pubkey = resolve_did(issuer_did).pubkey
        brand_pubkey =  resolve_did(brand_did).pubkey

        # 2-of-2 multiSig を作成
        redeem_script = Tapyrus::Script.new << 2 << [issuer_pubkey, brand_pubkey] << 2 << OP_CHECKMULTISIG
        script_pubkey = redeem_script.to_p2sh

        # カラー識別子を導出
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

    # アクワイアラとの契約締結
    def agreement_with_acquirer
      ActiveRecord::Base.transaction do
        acquirer_did = Did.find_or_create_by!(short_form: params[:did])
        acquirer = Acquirer.find_or_create_by!(name: params[:name], did: acquirer_did)
        brand_did = Did.first

        contracted_at = Time.current
        effect_at = 1.day.after
        expire_at = 3.year.after

        # MEMO: 一旦使わないのでスキップ
        # contract = Contract.create!(acquirer:, brand_did:, acquirer_did:,
        #                             contracted_at:, effect_at:, expire_at:)

        res = {
          contracted_at:, effect_at:, expire_at:,
          brand_did: brand_did.short_form
        }

        render json: res
      end
    end
  end
end

