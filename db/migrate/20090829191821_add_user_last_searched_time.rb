class AddUserLastSearchedTime < ActiveRecord::Migration
  def self.up
    add_column :users, :last_searched, :datetime
  end

  def self.down
    remove_column :users, :last_searched
  end
end
