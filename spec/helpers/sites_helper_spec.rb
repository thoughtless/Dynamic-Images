require File.dirname(__FILE__) + '/../spec_helper'

describe SitesHelper do
  include SitesHelper
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(SitesHelper)
  end
  
  describe "error message helper" do
  
    before(:each) do
      @errors = mock("errors")
      @site = mock_model(Site)
      @site.stub!(:errors).and_return @errors
    end
    
    it "should return the error messages wrapped in a div with class active-record-validation-errors" do
      @errors.stub!(:count).and_return(1)
      @errors.should_receive(:full_messages).and_return("My Error")
      error_messages_with_div_for_site.should have_tag('div[class=?]', 'active-record-validation-errors')
    end
    
    it "should return an empty string when there are no errors" do
      @errors.stub!(:count).and_return(0)
      @errors.should_not_receive(:full_messages)
      error_messages_with_div_for_site.should == ''
    end
  end
  
end
