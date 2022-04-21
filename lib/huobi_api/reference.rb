module HuobiApi
  module Reference
    def currencies(currency: nil)
      endpoint = '/v2/reference/currencies'

      get(endpoint, currency: currency)
    end
  end
end
