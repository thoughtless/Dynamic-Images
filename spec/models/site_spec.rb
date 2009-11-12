require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  before(:each) do
    #Create an empty site
    @site = Site.new
    
    #create a valid site
    @valid_user.stub!(:id).and_return(2)
    User.stub!(:find).with(@valid_user.id).and_return(@valid_user)
    s = Site.new(:address => valid_address)
    s.user_id = @valid_user.id
    @valid_site = s
  end

  it "should be invalid without a user" do
    @site.should have(1).error_on(:user_id)
  end
  
  it "should be invalid with an invalid user" do
    @site.user_id = 1
    @site.should have(1).error_on(:user_id)
  end
  
  it "should be valid with a valid user and address" do
    @valid_site.should be_valid
  end
  
  it "should have an address" do
    @site.should have(1).error_on(:address)
  end
  
  it "should have an address that starts with http:// and ends with /" do
    @site.address = 'http://valid/'
    @site.should have(0).errors_on(:address)
  end
  
  describe "address" do
    characters_not_allowed = %w('?' '&' '#' '"' '<' '>' " " ':' ';')
    characters_not_allowed.each do | c |
      it "should not allow #{c} in the host" do
        @site.address = 'http://test' + c + '/'
        @site.should have(1).error_on(:address)
      end
      it "should not allow #{c} in the path" do
        @site.address = 'http://test.com/test' + c + '/'
        @site.should have(1).error_on(:address)
      end
    end
    
    it "should automatically end with '/' when omitted by the user" do
      @valid_site.address = 'http://localhost'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should automatcially start with 'http://' when a scheme is omitted" do
      @valid_site.address = 'localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    describe "use of *" do
      it "should not be allow for top level domain" do
        @valid_site.address = 'http://domain.*/'
        @valid_site.save
        @valid_site.should have(1).error_on(:address)
      end
      it "should not be allow in the path" do
        @valid_site.address = 'http://domain.com/test/*/'
        @valid_site.save
        @valid_site.should have(1).error_on(:address)
      end
      it "should not be allow at the end of the path" do
        @valid_site.address = 'http://domain.com/test/test.*'
        @valid_site.save
        @valid_site.should have(1).error_on(:address)
      end
      it "should not be allow with a subdomain under it" do
        @valid_site.address = 'http://test.*.domain.com/'
        @valid_site.save
        @valid_site.should have(1).error_on(:address)
      end
      it "should not be allow if net set off by a ." do
        @valid_site.address = 'http://*domain.com/'
        @valid_site.save
        @valid_site.should have(1).errors_on(:address)
      end
      it "should be allowed at the start of the host" do
        @valid_site.address = 'http://*.domain.com/test/test/'
        @valid_site.save
        @valid_site.should have(0).errors_on(:address)
      end
    end
    it "should automatically strip out username/password" do
      @valid_site.address = 'http://paul:password@localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should automatically strip out username/password ':@' even if they don't exist'" do
      @valid_site.address = 'http://:@localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should automatically strip out username" do
      @valid_site.address = 'http://paul@localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should automatically strip out username with blank password" do
      @valid_site.address = 'http://paul:@localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should automatically strip out password with blank username" do
      @valid_site.address = 'http://:password@localhost/'
      @valid_site.save
      @valid_site.address.should == 'http://localhost/'
    end
    it "should not allow invalid schemes" do
      @valid_site.address = 'myprotocol://domain.com/'
      @valid_site.save
      @valid_site.should have(1).errors_on(:address)
    end
  end
  
  it "should not allow mass assignment for user_id" do
    s = Site.new(:address => valid_address, :user_id => @valid_user.id)
    s.should have(1).error_on(:user_id)
  end
  
  
  describe "validate_http_referer" do
    it "should match when the host is the same and there is no path" do
      @valid_site.address = 'http://google.com/'
      @valid_site.save!
      ref = 'http://google.com'
      @valid_site.validate_http_referer(ref).should be_true
    end
    it "should match all subdomains when there is a * at the start of the host" do
      @valid_site.address = 'http://*.google.com/'
      @valid_site.save!
      ref = 'http://www.google.com/'
      @valid_site.validate_http_referer(ref).should be_true
    end
    it "should match when there is no subdomain and there is a * at the start of the host" do
      @valid_site.address = 'http://*.google.com/'
      @valid_site.save!
      ref = 'http://google.com/'
      @valid_site.validate_http_referer(ref).should be_true
    end
    it "should not match subdomains when the host doesn't start with a *" do
      @valid_site.address = 'http://google.com/'
      @valid_site.save!
      ref = 'http://www.google.com/'
      @valid_site.validate_http_referer(ref).should be_false
    end
    it "should not match when the http_referer is for a subfolder not in the site's path" do
      @valid_site.address = 'http://www.google.com/apps/'
      @valid_site.save!
      ref = 'http://www.google.com/test/'
      @valid_site.validate_http_referer(ref).should be_false
    end
    it "should match when the http_referer is for a subfolder and the site has no subfolder" do
      @valid_site.address = 'http://www.google.com/'
      @valid_site.save!
      ref = 'http://www.google.com/test/'
      @valid_site.validate_http_referer(ref).should be_true
    end
    it "should match when the http_referer is for a subfolder within the site's subfolder" do
      @valid_site.address = 'http://www.google.com/apps/'
      @valid_site.save!
      ref = 'http://www.google.com/apps/test/'
      @valid_site.validate_http_referer(ref).should be_true
    end
    it "should require the scheme to match exactly" do
      @valid_site.address = 'http://www.google.com/'
      @valid_site.save!
      ref = 'https://www.google.com/'
      @valid_site.validate_http_referer(ref).should be_false
    end
  end
  
  def valid_address
    'http://www.google.com/'
  end
  
end



describe Site, "find_by_access_key" do
  it "should return all sites for the user whose access_key was provided" do
    # The find_by_access_key method users a find by sql so I can't mock the access_key and user objects
    u = new_valid_user
    a = new_valid_access_key u.id
    s = new_valid_site u.id
    Site.find_by_access_key(a.key).length.should == 2
    Site.find_by_access_key(a.key).each do |site|
      site.should respond_to('address')
    end
  end
  
  it "should return a site with http://localhost/ as the address for a new user" do
    u = new_valid_user
    a = new_valid_access_key u.id
    Site.find_by_access_key(a.key)[0].address.should == 'http://localhost/'
  end
  
  def new_valid_user
    u = User.new(:login => Time.now.to_s, 
                :email => Time.now.to_s.gsub(/[^0-9]/, '') + '@domain.com', 
                :password => 'password', 
                :password_confirmation => 'password' )
    u.save!
    u
  end
  
  def new_valid_access_key(user_id)
    a = AccessKey.new
    a.user_id = user_id
    a.save!
    a
  end
  
  def new_valid_site(user_id)
    s = Site.new(:address => 'http://' + Time.now.to_s.gsub(/[^0-9]/, '') + '/')
    s.user_id = user_id
    s.save!
    s
  end
  
end



