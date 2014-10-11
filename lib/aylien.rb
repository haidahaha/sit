require 'net/http'
require 'uri'
require 'json'

APPLICATION_ID = "413be626"
APPLICATION_KEY = "9a02ea94fbd57c60faef291ab8d610e5"

class Aylien

    def self.get_hashtags(url)
      result = Aylien.call_api("hashtags", {"url" => url})
      return result["hashtags"]
    end
    
    protected
    def self.call_api(endpoint, parameters)
      url = URI.parse("https://api.aylien.com/api/v1/#{endpoint}")
      headers = {
          "Accept"                           =>   "application/json",
          "X-AYLIEN-TextAPI-Application-ID"  =>   APPLICATION_ID,
          "X-AYLIEN-TextAPI-Application-Key" =>   APPLICATION_KEY
      }

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(url.request_uri)
      request.initialize_http_header(headers)
      request.set_form_data(parameters)

      response = http.request(request)

      JSON.parse response.body
    end
end
