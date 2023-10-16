brand_did = Did.create!(short_form: ENV['BRAND_DID'])
brand_key = Key.create!(jwk: ENV['BRAND_DID_JWK'], did: brand_did)
