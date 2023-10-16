class StableCoinsController < ApplicationController
  protect_from_forgery

  # コイン発行
  def issue
    ActiveRecord::Base.transaction do
      color_id = params[:color_id]
      stable_coin = StableCoin.find_by(color_id:)
      script_pubkey = stable_coin.contract.script_pubkey
      unsigned_tx_hex = params[:unsigned_tx]

      tx = Tapyrus::Tx.parse_from_payload(unsigned_tx_hex.htb)

      # memo: outputsに複数トークンきたら詰む
      index = 0
      tx.outputs.each do |output, i|
        index = i if output.color_id == color_id
      end

      sig_hash = tx.sighash_for_input(index, script_pubkey)
      key = Did.brand.key.to_tapyrus_key
      signature = key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack('C')

      res = {
        signature: signature.bth
      }

      render json: res
    end
  end
end
