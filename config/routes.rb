Rails.application.routes.draw do
  post 'contracts/agreement/issuer', to: 'contracts#agreement_with_issuer'
end
