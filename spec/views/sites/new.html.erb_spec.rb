require File.dirname(__FILE__) + '/../../spec_helper'

describe "users/2/sites/new.html.erb" do
  include SitesHelper
  
  before(:each) do
    log_in_a_user
    @site = mock_model(Site)
    @site.stub!(:new_record?).and_return(true)
    @site.stub!(:address).and_return("MyString")
    @site.stub!(:user_id).and_return(@logged_in_user.id)
    assigns[:site] = @site
  end

  it "should render new form" do
    render "sites/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", user_sites_path(:user_id => @logged_in_user.id)) do
      with_tag("input#site_address[name=?]", "site[address]")
    end
  end
end


