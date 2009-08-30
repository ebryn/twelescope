module Rehab
  module Enqueueable
    def enqueue
      Delayed::Job.enqueue self
    end
  end
end
