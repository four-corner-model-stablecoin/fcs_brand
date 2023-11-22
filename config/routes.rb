Rails.application.routes.draw do
  resources :accounts, only: %i[] do
    resources :account_transactions, only: %i[index]
  end

  namespace :api do
    post 'contracts/agreement/issuer', to: 'contracts#agreement_with_issuer'
    post 'contracts/agreement/acquirer', to: 'contracts#agreement_with_acquirer'

    post 'stable_coins/issue', to: 'stable_coins#issue'

    post 'withdraw/create', to: 'withdraws#create'
    post 'withdraw/confirm', to: 'withdraws#confirm'
  end
end
