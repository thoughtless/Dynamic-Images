require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  describe "valid_access_key? methed" do
    describe "receiving an access key with no sites" do
      it "should render a 404 failure" do
        a = ApplicationController.new
        a.stub!(:params).and_return({:access_key => '123'})
        Site.should_receive(:find_by_access_key).with('123').and_return([])
        a.should_receive(:http_referer_valid?).and_return(true)
        a.stub!(:request)
        a.request.stub!(:headers).and_return({'HTTP_REFERER' => nil})
        
        a.should_receive(:render).with(:file => "#{RAILS_ROOT}/public/404.html", :status => 404)
        a.valid_access_key?
      end
    end
    describe "receiving an access key with a valid site" do
      it "should not render anything" do
        site = mock_model(Site)
        a = ApplicationController.new
        a.stub!(:params).and_return({:access_key => '123'})
        Site.should_receive(:find_by_access_key).with('123').and_return([site])
        a.should_receive(:http_referer_valid?).and_return(true)
        a.stub!(:request)
        a.request.stub!(:headers).and_return({'HTTP_REFERER' => nil})
        
        a.should_not_receive(:render)
        a.valid_access_key?
      end
    end
  end
end
