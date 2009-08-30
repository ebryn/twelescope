class LoadingUser < ActiveRecord::Migration
  def self.up
    add_column :users, :loading, :boolean
  end

  def self.down
    remove_column :users, :loading
  end
end
