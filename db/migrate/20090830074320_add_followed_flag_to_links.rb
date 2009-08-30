class AddFollowedFlagToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :followed, :boolean, :default => false, :nil => false
    
    Link.update_all ["followed = ?", true], ["id IN (?)", ShortLink.count(:id, :group => 'link_id').map(&:first)]
  end

  def self.down
    remove_column :links, :followed
  end
end
