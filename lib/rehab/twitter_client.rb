module Rehab
  class TwitterClient
    class NoSuchUser < StandardError; end
    include Typhoeus
    remote_defaults :on_success => lambda {|response| 
      parsed_response = JSON.parse(response.body)
      if parsed_response.respond_to? :keys
        HashWithIndifferentAccess.new parsed_response
      elsif parsed_response.respond_to? :map
        parsed_response.map { |r| HashWithIndifferentAccess.new r } 
      else
        []
      end
    },
     :on_failure => lambda {|response| 
      puts "error code: #{response.body}"
      parsed_error = JSON.parse(response.body)
      raise NoSuchUser if parsed_error['error'] == "Not found"
    },
     :base_uri => "http://twitter.com/"

    define_remote_method :friends, :path => 'statuses/friends/:user.json'
  end

end
