module Rehab
  module Enqueueable
    QUEUE_PRIORITY = 5
    def enqueue
      Delayed::Job.enqueue self, queue_priority
    end
    def enqueueable?
      true
    end

    def queue_priority
      QUEUE_PRIORITY
    end
  end
end
