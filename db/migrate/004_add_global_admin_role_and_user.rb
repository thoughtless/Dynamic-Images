require 'user'

class User < ActiveRecord::Base
  def after_create
    # don't run the after create because it depends on future migrations
  end
end

class AddGlobalAdminRoleAndUser < ActiveRecord::Migration
  # create a global admin that will be able to do anything
  # set up a temporary password that can be changed later
  # this user will be used to create the first real users
  
  def self.up
    unless r = Role.find_by_name(self.global_admin)
      r = Role.new(:name => self.global_admin)
      r.save!
    end
    
    unless User.find_by_login(self.global_admin)
      u = User.new(:login => self.global_admin,
                    :email => self.default_email,
                    :password => 'secret',
                    :password_confirmation => 'secret')
      u.roles << r
      u.save!
    end
    
  end

  def self.down
    u = User.find_by_login_and_email(self.global_admin, self.default_email)  #Don't delete the admin if the email address has been changed
    u.destroy if u
    
    r = Role.find_by_name(self.global_admin)
    r.destroy if r.users.count == 0  # don't erase the role if users belong to it
  end
  
  def self.global_admin
    'global_admin'
  end
  
  def self.default_email
    'change@me.now'
  end
end
