class Linkage < ActiveRecord::Base
  belongs_to :link, :counter_cache => true
  belongs_to :domain, :counter_cache => true
  belongs_to :user

  #named_scope :popular, :select => "*, count(id) as qty", :order => "count(linkages.id) desc", :group => "link_id", :limit => 25

end
