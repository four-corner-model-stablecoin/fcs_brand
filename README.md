# Brand server

## イシュア契約

### [POST] /contracts/agreement/issuer

- params
  ```json
  {
    "name": string,
    "did": string
  }
  ```
- return
  ```json
  {
    "color_id": string,
    "script_pubkey": string,
    "redeem_script": string,
    "contracted_at": datetime, 
    "effect_at": datetime, 
    "expire_at": datetime,
    "brand_did": string
  }
  ```
