require "lib/rehab/twitter_client"
module Rehab
  class SearchTwitterClient < TwitterClient
    remote_defaults :base_uri => "http://search.twitter.com/"

    define_remote_method :query, :path => '/search.json'
    define_remote_method :trends, :path => '/trends/:time_frame.json'
  end
end
