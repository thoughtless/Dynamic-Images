class AddAccessKeysUserIdIndex < ActiveRecord::Migration
  def self.up
    add_index :access_keys, :user_id
  end

  def self.down
    remove_index :access_keys, :user_id
  end
end
