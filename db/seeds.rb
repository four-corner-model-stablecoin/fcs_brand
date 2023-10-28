# frozen_string_literal: true

brand_did = Did.create!(short_form: "did:ion:EiC_pmuSjG4VMd61m-ScQkg7YPVVX6-Mo9Fn_cMGZmPoJw")
jwk = {
  "kty": "EC",
  "crv": "secp256k1",
  "x": "Sp1zTvtooTckKLn1e5mZ1lRyOruVZen918HW3HQxbFc",
  "y": "OKGyUbaELSi4fbu0CeqkMkZEMrbjyDxx1cvQIcSO0Kw",
  "d": "zxHazfJ2WAiPsk6I16ek0jwv1hzqxXLDyrZqQCIMrB4"
}
Key.create!(did: brand_did, jwk: jwk.to_json)

if Glueby::AR::SystemInformation.synced_block_height.nil?
  Glueby::AR::SystemInformation.create!(info_key: 'synced_block_number', info_value: '0')
end

address = Glueby::Internal::RPC.client.getnewaddress
aggregate_private_key = ENV['TAPYRUS_AUTHORITY_KEY']
Glueby::Internal::RPC.client.generatetoaddress(1, address, aggregate_private_key)

latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end
