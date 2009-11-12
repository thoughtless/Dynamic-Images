class AddSitesUserIdIndex < ActiveRecord::Migration
  def self.up
    add_index :sites, :user_id
  end

  def self.down
    remove_index :sites, :user_id
  end
end
