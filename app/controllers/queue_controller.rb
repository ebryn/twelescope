class QueueController < ApplicationController
  def index
    @jobs = Delayed::Job.find(:all, :order => 'priority DESC, run_at ASC', :limit => 200)
  end
end
