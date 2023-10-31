# frozen_string_literal: true

module Account
  class AccountTransactionsController < ApplicationController
    def index
      @account = Account.find(params[:account_id])
      @account_transactions = @account.account_transactions
    end
  end
end
