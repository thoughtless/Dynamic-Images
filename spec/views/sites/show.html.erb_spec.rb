require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/show.html.erb" do
  include SitesHelper
  
  before(:each) do
    log_in_a_user
    
    @site = mock_model(Site)
    @site.stub!(:address).and_return("MyString")
    @site.stub!(:user_id).and_return(@logged_in_user.id)

    assigns[:site] = @site
  end

  it "should render attributes in <p>" do
    render "/sites/show.html.erb"
    response.should have_text(/MyString/)
  end
end

