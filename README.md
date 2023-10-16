# Brand server

## イシュア契約

### [POST] /contracts/agreement/issuer

- params
  ```
  {
    "name": string,
    "did": string
  }
  ```
- return
  ```
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

## コイン発行

### [POST] /stable_coins/issue

- params
  ```
  {
    "color_id": string,
    "unsigned_tx": string
  }
  ```
- return
  ```
  {
    "signature": string
  }
  ```
