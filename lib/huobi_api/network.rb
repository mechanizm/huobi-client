require 'base64'
require 'rack'
require 'openssl'
require 'net/http'
require 'json'

module HuobiApi
  module Network

    BASE_URL='https://api.huobi.pro'.freeze
    SIGNATURE_VERSION=2
    HEADERS={
      'Content-Type'=> 'application/json',
      'Accept' => 'application/json',
      'Accept-Language' => 'en-GB',
    }.freeze

    def post(endpoint, data)
      request(endpoint, :POST, data)
    end

    def get(endpoint, data)
      request(endpoint, :GET, data)
    end

    def request(endpoint, method, data)
      version_match = endpoint.match(/^\/v(\d)\//)

      raise 'Unrecognized API version query' if version_match.nil?

      version = version_match[1].to_i

      uri = URI.parse(BASE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      params = build_params(endpoint, method, data)
      url = "#{BASE_URL}#{endpoint}?#{Rack::Utils.build_query(params)}"

      payload = (method == :POST ? JSON.dump(data) : nil)
      response = JSON.parse(http.send_request(method, url, payload, HEADERS).body)

      ensure_success!(version, response)
    end

    private

    def ensure_success!(version, response)
      case version
      when 1
        raise response['err-msg'] if response['status'] == 'error'
      when 2
        raise response['message'] if response['code'] != 200
      else
        raise "Version #{version} is not supported"
      end

      response
    end

    def build_params(endpoint, method, data)
      # things huobi want you to send (and sign)
      params = {
        'AccessKeyId' => HuobiApi.key,
        'SignatureMethod' => 'HmacSHA256',
        'SignatureVersion' => SIGNATURE_VERSION,
        'Timestamp' => Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%S")
      }

      # add in what we're sending, if it's a get request
      params.merge!(data.compact.stringify_keys) if method.to_s.upcase == "GET"
      # alphabetical order, as that's what huobi likes
      sorted_params = hash_sort(params)
      #  now mash into a query string
      query_string = Rack::Utils.build_query(sorted_params)
      # now add some other random shit
      to_sign = "#{method.to_s.upcase}\napi.huobi.pro\n#{endpoint}\n#{query_string}"
      # now sign in
      sig = sign(to_sign)
      # and mash it into the params
      params['Signature'] = sig

      params
    end

    def sign(data)
      Base64.encode64(OpenSSL::HMAC.digest('sha256', HuobiApi.secret, data)).gsub("\n","")
    end

    def hash_sort(ha)
      Hash[ha.sort_by{ |k, _| k }]
    end
  end
end
