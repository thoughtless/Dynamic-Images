require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe User do

  before(:each) do
    @fred = create_user
  end

  it "should have 1 access_key after creation" do
    @fred.access_keys.count.should eql(1)
  end

  it "should have 1 site after creation" do
    @fred.sites.count.should eql(1)
  end
  
  it "should be valid" do
    @fred.should be_valid
  end

  it "should not allow the login to change" do
    @fred.login = 'quentin'
    @fred.should_not be_valid
    @fred.save.should be_false
    
  end
  
  it "should be able to be a global admin" do
    admin_role = mock_model(Role)
    admin_role.stub!(:name).and_return('global_admin')
    @fred.stub!(:roles).and_return([admin_role])
    @fred.has_role?('global_admin').should be_true
  end
  
  it "should not have the global admin role when it hasn't been added" do
    @fred.has_role?('global_admin').should be_false
  end
  
  it "should authenticate with the correct login and password" do
    User.authenticate('fred', 'secret').should == @fred
  end
  
  it "should not authenticate with the wrong login and correct password" do
    User.authenticate('freddie', 'secret').should be_nil
  end
  
  it "should not authenticate with the correct login and wrong password" do
    User.authenticate('fred', 'password').should be_nil
  end
  
  it "should not authenticate with the wrong login and wrong password" do
    User.authenticate('freddie', 'password').should be_nil
  end
  
  def create_user
    User.create(:login => 'fred',
      :email => 'fred@fred.net',
      :password => 'secret',
      :password_confirmation => 'secret')
  end
end
