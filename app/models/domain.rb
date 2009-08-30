class Domain < ActiveRecord::Base
  has_many :links
  has_many :linkages

  named_scope :popular, :order => "domains.linkages_count DESC", :limit => 25
end
