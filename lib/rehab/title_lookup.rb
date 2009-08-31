module Rehab
  class TitleLookup
    include Typhoeus
    remote_defaults :on_success => lambda {|response| 
      Nokogiri.HTML( response.body ).at("//title").text.strip rescue nil
    },
     :on_failure => lambda {|response| 
      nil
    }

    define_remote_method :find
  end

end
