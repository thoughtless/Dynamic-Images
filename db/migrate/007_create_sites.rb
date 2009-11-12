class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.column :address, :string
      t.column :user_id, :integer

      t.timestamps
    end
    
    # Add the site 'http://localhost/' as a site for each user
    
    User.find(:all).each do |u|
      s = Site.new(:address => 'http://localhost/')
      s.user_id = u.id
      s.save!
    end
  end

  def self.down
    drop_table :sites
  end
end
