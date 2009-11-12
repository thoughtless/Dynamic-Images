class CreateCorners < ActiveRecord::Migration
  def self.up
    create_table :corners do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :corners
  end
end
