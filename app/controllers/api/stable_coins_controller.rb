# frozen_string_literal: true

module Api
  class StableCoinsController < ApplicationController
    protect_from_forgery

    # コイン発行
    # イシュアからリクエストを受付け、署名して返送
    def issue
      ActiveRecord::Base.transaction do
        color_id = params[:color_id]
        stable_coin = StableCoin.find_by(color_id:)
        redeem_script = Tapyrus::Script.parse_from_payload(stable_coin.contract.redeem_script.htb)
        unsigned_tx_hex = params[:unsigned_tx]

        tx = Tapyrus::Tx.parse_from_payload(unsigned_tx_hex.htb)

        sig_hash = tx.sighash_for_input(0, redeem_script)
        key = Did.first.key.to_tapyrus_key
        signature = key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack('C')

        res = {
          signature: signature.bth
        }

        render json: res
      end
    end
  end
end
