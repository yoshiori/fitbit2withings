require "fitgem"

module Fitbit2withings
  class FitbitClient
    CLIENT_DUMP_PATH = "client"

    def response
      @response ||= begin
        res = client.body_weight(date: 'today')["weight"]
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
      response["weight"] / 2.2046 if response["weight"]
    end

    def client
      @client ||=
        if File.exist?(CLIENT_DUMP_PATH)
          Marshal.load(File.read(CLIENT_DUMP_PATH))
        else
          refresh_client
        end
    end

    def refresh_client
      client = Fitgem::Client.new(
        consumer_key: ENV["FITBIT_CONSUMER_KEY"],
        consumer_secret: ENV["FITBIT_CONSUMER_SECRET"],
      )
      request_token = client.request_token
      token = request_token.token
      secret = request_token.secret
      puts "Go to https://www.fitbit.com/oauth/authorize?oauth_token=#{token}"
      puts "and then enter the verifier code below"
      verifier = gets.chomp
      client.authorize(token, secret, oauth_verifier: verifier)
      File.open(CLIENT_DUMP_PATH, "w") do |f|
        f.write(Marshal.dump(client))
      end
      client
    end
  end
end
