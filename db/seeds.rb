# frozen_string_literal: true

brand_did = Did.create!(short_form: "did:ion:EiCZI36gD-gRcHwJGAppxi6bXQfnEGoVD8bAqPt4k4kjRw:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJzaWduaW5nLWtleSIsInB1YmxpY0tleUp3ayI6eyJjcnYiOiJzZWNwMjU2azEiLCJrdHkiOiJFQyIsIngiOiJUY0U4RmtlMUtIelFnRXd2X1pmNTRQLUJNLUR1bEtIYW9KUHEtVV9Fc184IiwieSI6IkpMaG1YbTR6WVo1T1kxX1JKcUdza3FpREE0M1doMFR5ekRxeTUwR29Va2MifSwicHVycG9zZXMiOlsiYXV0aGVudGljYXRpb24iXSwidHlwZSI6IkVjZHNhU2VjcDI1NmsxVmVyaWZpY2F0aW9uS2V5MjAxOSJ9XSwic2VydmljZXMiOltdfX1dLCJ1cGRhdGVDb21taXRtZW50IjoiRWlBVGpZU3Mzb0VmdExZTmstT2paODlKNjMwQ2lFZmVSNU1OY3E0RG9BQ21EdyJ9LCJzdWZmaXhEYXRhIjp7ImRlbHRhSGFzaCI6IkVpRHlJaTVVZGZRWHd3dnVqLXQ1ZUZQeWtnX1lSZTZjZnVYenAySjBNSGsxR1EiLCJyZWNvdmVyeUNvbW1pdG1lbnQiOiJFaURNRkR1Y0VGNUpaUGYzV25xLWhVS09nREl4ektjUXpfRzBEeUR1VmlabnF3In19")
jwk = {
  "kty": "EC",
  "crv": "secp256k1",
  "x": "TcE8Fke1KHzQgEwv_Zf54P-BM-DulKHaoJPq-U_Es_8",
  "y": "JLhmXm4zYZ5OY1_RJqGskqiDA43Wh0TyzDqy50GoUkc",
  "d": "Bbo-XIXn7loQMFejOHs7EgJQ-jctotOMRicWMiLA2BM"
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
