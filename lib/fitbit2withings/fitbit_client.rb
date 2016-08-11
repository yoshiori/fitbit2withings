require "oauth2"
require "base64"

module Fitbit2withings
  class FitbitClient
    TOKEN_PATH = ".access_token".freeze

    def response
      @response ||= begin
        today = Date.today.strftime("%Y-%m-%d")
        url = "https://api.fitbit.com/1/user/-/body/log/weight/date/#{today}.json"
        res = JSON.parse(token.get(url).body)["weight"]
        if res.empty?
          {}
        else
          res.first
        end
      end
    end

    def fat
      response["fat"]
    end

    def weight
      response["weight"]
    end

    def token
      @token ||= File.exist?(TOKEN_PATH) ? load_token : create_token
    end

    def load_token
      token = OAuth2::AccessToken.from_hash(client, JSON.parse(File.read(TOKEN_PATH)))
      if token.expired?
        token = token.refresh!(headers)
        File.write(TOKEN_PATH, token.to_hash.to_json)
      end
      token
    end

    def create_token
      url = client.auth_code.authorize_url(scope: "weight")
      puts "Go to #{url}"
      puts "and then enter the authorization code below"
      code = gets.chomp
      token = client.auth_code.get_token(code, headers)
      File.write(TOKEN_PATH, token.to_hash.to_json)
      token
    end

    def client
      @client ||= OAuth2::Client.new(
        ENV["FITBIT_CLIENT_ID"],
        ENV["FITBIT_CLIENT_SECRET"],
        site: "https://api.fitbit.com",
        authorize_url: "https://www.fitbit.com/oauth2/authorize",
        token_url: "https://api.fitbit.com/oauth2/token",
      )
    end

    def headers
      { headers: { Authorization:  "Basic #{encoded_bearer_token}" } }
    end

    def encoded_bearer_token
      Base64.strict_encode64("#{ENV['FITBIT_CLIENT_ID']}:#{ENV['FITBIT_CLIENT_SECRET']}")
    end
  end
end
