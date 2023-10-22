Rails.application.routes.draw do
  post 'contracts/agreement/issuer', to: 'contracts#agreement_with_issuer'
  post 'contracts/agreement/acquirer', to: 'contracts#agreement_with_acquirer'
  post 'stable_coins/issue', to: 'stable_coins#issue'
end
