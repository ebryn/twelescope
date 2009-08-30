class FixDomains < ActiveRecord::Migration
  def self.up
    begin
      Link.set_domain_fields
    rescue SQLite3::SQLException => e
    end
  end

  def self.down
  end
end
