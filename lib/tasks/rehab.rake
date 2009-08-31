require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
namespace :rehab do
  task :update_domains do
    Link.find_in_batches( :conditions => [ "original_url IS NULL and followed = ?", false] ) do |links|
      links.each do |link|
        begin
          next if link.followed? or link.original_url
          link.expand_url
          link.save!
        rescue => e
          nil
        end
      end
    end
  end
end
