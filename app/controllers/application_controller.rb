class ApplicationController < ActionController::Base
  helper_method :generate_block, :resolve_did
  protect_from_forgery

  private

  # TODO: ヘルパーに切り出す

  def generate_block
    address =  Glueby::Internal::RPC.client.getnewaddress
    aggregate_private_key = ENV['TAPYRUS_AUTHORITY_KEY']
    Glueby::Internal::RPC.client.generatetoaddress(1, address, aggregate_private_key)

    latest_block_num = Glueby::Internal::RPC.client.getblockcount
    synced_block = Glueby::AR::SystemInformation.synced_block_height
    (synced_block.int_value + 1..latest_block_num).each do |height|
      Glueby::BlockSyncer.new(height).run
      synced_block.update(info_value: height.to_s)
    end
  end

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
