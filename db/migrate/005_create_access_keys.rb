class CreateAccessKeys < ActiveRecord::Migration
  def self.up
    create_table :access_keys do |t|
      t.column :key, :string
      t.column :user_id, :integer
      t.column :enabled, :boolean, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :access_keys
  end
end
