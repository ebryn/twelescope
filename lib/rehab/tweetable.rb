module Rehab
  module Tweetable

    def twitter
      Rehab::TwitterClient
    end

    def search_twitter
      Rehab::SearchTwitterClient
    end

  end
end
