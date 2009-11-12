require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/edit.html.erb" do
  include SitesHelper
  
  before do
    log_in_a_user
    
    @site = mock_model(Site)
    @site.stub!(:address).and_return("MyString")
    @site.stub!(:user_id).and_return(@logged_in_user.id)
    assigns[:site] = @site
  end

  it "should render edit form" do
    render "/sites/edit.html.erb"
    
    response.should have_tag("form[action=#{user_site_path(:id => @site, :user_id => @logged_in_user.id)}][method=post]") do
      with_tag('input#site_address[name=?]', "site[address]")
    end
  end
end


