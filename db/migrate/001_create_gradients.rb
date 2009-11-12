class CreateGradients < ActiveRecord::Migration
  def self.up
    create_table :gradients do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :gradients
  end
end
