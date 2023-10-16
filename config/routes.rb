Rails.application.routes.draw do
  post 'contracts/agreement/issuer', to: 'contracts#agreement_with_issuer'
  post 'stable_coins/issue', to: 'stable_coins#issue'
end
