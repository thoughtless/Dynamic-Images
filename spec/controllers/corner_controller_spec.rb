require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

require 'RMagick'

describe CornerController do
  before(:each) do
    @site = mock_model(Site, :address => 'http://localhost/')
    @sites = [@site]
    Site.stub!(:find_by_access_key).with("myaccesskey").and_return(@sites)
    Site.stub!(:find_by_access_key).with("invalidaccesskey").and_return([])
    Site.stub!(:find_by_access_key).with(nil).and_return([])
  end
  
  describe "with HTTP_REFERER" do
    before(:each) do
    end
    
    it "should be unsuccessful when HTTP_REFERER is not from a permitted site" do
      @site.should_receive(:validate_http_referer).with('http://www.google.ca/test/blah.html').and_return(false)
      request.headers["HTTP_REFERER"] = 'http://www.google.ca/test/blah.html'
      get 'index', :access_key => 'myaccesskey', :specs => []
      response.should_not be_success
    end
    it "should be successful when HTTP_REFERER is from a permitted site" do
      @site.should_receive(:validate_http_referer).with('http://localhost:3000/test/blah.html').and_return(true)
      request.headers["HTTP_REFERER"] = 'http://localhost:3000/test/blah.html'
      get 'index', :access_key => 'myaccesskey', :specs => []
      response.should be_success
    end
    it "should be successful when HTTP_REFERER is nil" do
      request.headers["HTTP_REFERER"] = nil
      get 'index', :access_key => 'myaccesskey', :specs => []
      response.should be_success
    end
    it "should be successful when HTTP_REFERER is not set" do
      get 'index', :access_key => 'myaccesskey', :specs => []
      response.should be_success
    end
  end

  describe "requesting an image" do
    integrate_views
    
    before(:each) do
    end
  
    it "should be successful" do
      get 'index', :access_key => 'myaccesskey', :specs => []
      response.should be_success
    end
    
    it "should fail without an access_key" do
      get 'index', :specs => []
      response.should_not be_success
    end
    
    it "should fail with an invalid access_key" do
      get 'index', :access_key => 'invalidaccesskey', :specs => []
      response.should_not be_success
    end
    
    it "should be the specified 45 width and height" do
      get 'index', :access_key => 'myaccesskey', :specs => %w(direction top-left from white to black size 45 size_alt 45)
      image = Magick::Image.from_blob(response.binary_content)[0]
      
      image.rows.should equal(45)
      image.columns.should equal(45)
      
    end
  
    it "should match the top-left fixture" do
      fixture = Magick::Image.read(File.expand_path(File.dirname(__FILE__)) + '/../fixtures/img/corner_direction_top-left_from_white_size_50_to_black.png')[0]
      
      get 'index', :access_key => 'myaccesskey', :specs => %w(direction top-left from white to black size 50)
      result = Magick::Image.from_blob(response.binary_content)[0]
      
      result.to_blob.should eql(fixture.to_blob)
      
    end
  
    it "should match the bottom green to red fixture" do
      fixture = Magick::Image.read(File.expand_path(File.dirname(__FILE__)) + '/../fixtures/img/corner_curve_0.7_direction_bottom-right_from_22ee44_size_90_to_ff1111.png')[0]
      
      get 'index', :access_key => 'myaccesskey', :specs => %w(curve 0.7 direction bottom-right from 22ee44 to ff1111 size 90)
      result = Magick::Image.from_blob(response.binary_content)[0]
  
      result.to_blob.should eql(fixture.to_blob)
      
    end
    
  #  it "should cache images after the first time they are generated" do
  #    pending
  #  end
  end
end


describe CornerController, "benchmark" do
  integrate_views

  before(:each) do
    @user = User.create(:login => 'paul', :email => 'paul@paul.com', :password => 'password', :password_confirmation => 'password')
    request.headers["HTTP_REFERER"] = 'http://localhost/'
  end
  
  it "should be fast" do
    result = Benchmark.realtime do
      (1..150).each do
        get 'index', :access_key => @user.access_keys[0].key, :specs => []
      end
    end
    result.should < 1.0
    
  end
end
