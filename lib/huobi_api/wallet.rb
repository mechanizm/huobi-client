module HuobiApi
  module Wallet
    def deposit_address(currency:)
      endpoint = '/v2/account/deposit/address'
      get(endpoint, currency: currency)
    end

    def deposits(currency:, from: nil, size: nil, direct: 'next')
      endpoint = '/v1/query/deposit-withdraw'
      get(
        endpoint,
        currency: currency,
        from: from,
        size: size,
        direct: direct,
        type: 'deposit'
      )
    end

    def request_withdraw(
      address:,
      currency:,
      amount:,
      fee: nil,
      chain: nil,
      addr_tag: nil,
      client_order_id: nil
    )
      endpoint = '/v1/dw/withdraw/api/create'
      post(
        endpoint,
        address: address,
        currency: currency,
        chain: chain,
        amount: amount,
        fee: fee,
        'addr-tag' => addr_tag,
        'client-order-id' => client_order_id
      )
    end
  end
end
