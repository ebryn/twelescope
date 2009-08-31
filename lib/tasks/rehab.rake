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
          puts " attempting link #{link.url}"
          link.expand_url
          puts " result #{link.url}\n\n"
          link.save!
        rescue => e
          nil
        end
      end
    end
  end
end
