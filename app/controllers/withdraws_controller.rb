# frozen_string_literal: true

class WithdrawsController < ApplicationController
  def create
    request_id = params[:request_id]
    amount = params[:amount]
    acquirer_did = Did.find_by!(short_form: params[:acquirer_did])
    merchant_to_brand_txid = params[:merchant_to_brand_txid]
    merchant_to_brand_tx = Tapyrus::Tx.parse_from_payload(Glueby::Internal::RPC.client.getrawtransaction(merchant_to_brand_txid).htb)

    # brand key
    brand_key = Did.first.key.to_tapyrus_key

    # token outpoint
    # vout = 0 で決めうち
    token_outpoint = Tapyrus::OutPoint.from_txid(merchant_to_brand_txid, 0)
    token_output = merchant_to_brand_tx.outputs.first
    token_script_pubkey = token_output.script_pubkey
    color_identifier = token_script_pubkey.color_id
    stable_coin = StableCoin.find_by!(color_id: color_identifier.to_payload.bth)
    issuer = stable_coin.contract.issuer
    issuer_key = resolve_did(issuer.did)

    request = WithdrawalRequest.create!(
      request_id:, issuer:, acquirer: acquirer_did.acquirer, stable_coin:, amount:,
      merchant_to_brand_txid: merchant_to_brand_txid, status: :created
    )

    tx = Tapyrus::Tx.new

    # fill token
    tx.in << Tapyrus::TxIn.new(out_point: token_outpoint)
    tx.out << Tapyrus::TxOut.new(value: token_output.value, script_pubkey: Tapyrus::Script.to_cp2pkh(color_identifier, Tapyrus.hash160(issuer_key.pubkey)))

    # fill TPC as fee
    utxo = Glueby::Internal::RPC.client.listunspent.first
    tx.in << Tapyrus::TxIn.new(out_point: Tapyrus::OutPoint.from_txid(utxo['txid'], utxo['vout']))
    fee_tapyrus = (0.00003 * (10**8)).to_i
    input_tapyrus = (utxo['amount'].to_f * (10**8)).to_i
    change_tapyrus = input_tapyrus - fee_tapyrus
    tx.out << Tapyrus::TxOut.new(value: change_tapyrus, script_pubkey: Tapyrus::Script.parse_from_addr(Glueby::Internal::RPC.client.getnewaddress))

    # sign for token
    sig_hash = tx.sighash_for_input(0, token_script_pubkey)
    sig = brand_key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack("C")
    tx.in[0].script_sig << sig
    tx.in[0].script_sig << brand_key.pubkey

    # sign for TPC
    script_pubkey = Tapyrus::Script.parse_from_payload(utxo['scriptPubKey'].htb)
    key = Tapyrus::Key.from_wif(Glueby::Internal::RPC.client.dumpprivkey(script_pubkey.to_addr))
    sig_hash = tx.sighash_for_input(1, script_pubkey)
    sig = key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack("C")
    tx.in[1].script_sig << sig
    tx.in[1].script_sig << key.pubkey

    brand_to_issuer_txid = Glueby::Internal::RPC.client.sendrawtransaction(tx.to_payload.bth)

    request.update!(brand_to_issuer_txid:, status: :transfering)

    # MEMO: 本来は非同期に実行、デモではgenerate_blockを用いて同期実行
    # if ENV['DEMO'] = 1
    generate_block

    json = {
      request_id:,
      amount:,
      merchant_to_brand_txid:,
      brand_to_issuer_txid:
    }.to_json
    response = Net::HTTP.post(
      URI("#{ENV['ISSUER_URL']}/withdraw/create"),
      json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    burn_txid = body['burn_txid']

    request.update!(burn_txid:)

    issuer_account = request.issuer.account
    issuer_account.update!(balance: issuer_account.balance - amount)
    AccountTransaction.create!(
      account: issuer_account,
      amount: -amount,
      transaction_type: :transfer,
      transaction_time: DateTime.current
    )

    acquirer_account = request.acquirer.account
    acquirer_account.update!(balance: acquirer_account.balance + amount)
    AccountTransaction.create!(
      account: acquirer_account,
      amount:,
      transaction_type: :transfer,
      transaction_time: DateTime.current
    )

    render json: { brand_to_issuer_txid:, burn_txid: }
  end

  def confirm
  end
end
