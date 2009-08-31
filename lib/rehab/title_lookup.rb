module Rehab
  class TitleLookup
    include Typhoeus
    remote_defaults :on_success => lambda {|response| 
       headers = HashWithIndifferentAccess[ *response.headers.split( "\r\n" ).delete_if { |h| h =~ /^HTTP/ }.map { |x| x.split(": ",2) }.flatten ]
       return nil unless headers['Content-Type'] =~ /(xml|html)/
      Nokogiri.HTML( response.body ).at("//title").text.strip rescue nil
    },
     :on_failure => lambda {|response| 
      nil
    }

    define_remote_method :find
  end

end
