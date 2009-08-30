module Rehab
  class UrlLookup
    include Typhoeus
    remote_defaults :on_success => lambda {|response| 
      true
    },
     :on_failure => lambda {|response| 
       headers = HashWithIndifferentAccess[ *response.headers.split( "\r\n" ).delete_if { |h| h =~ /^HTTP/ }.map { |x| x.split(": ",2) }.flatten ]
       headers[:Location] if [ 301, 302].include? response.code
    }

    define_remote_method :follow
  end

end
