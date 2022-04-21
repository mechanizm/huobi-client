require 'huobi_api/network'
require 'huobi_api/accounts'
require 'huobi_api/orders'
require 'huobi_api/wallet'
require 'huobi_api/reference'

module HuobiApi
  class Client
    include HuobiApi::Network
    include HuobiApi::Orders
    include HuobiApi::Accounts
    include HuobiApi::Wallet
    include HuobiApi::Reference
  end
end
