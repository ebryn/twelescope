module Rehab
  module Enqueueable
    def enqueue
      Delayed::Job.enqueue self, (defined?(self.class::QUEUE_PRIORITY) ? self.class::QUEUE_PRIORITY : 0)
    end
    def enqueueable?
      true
    end
  end
end
