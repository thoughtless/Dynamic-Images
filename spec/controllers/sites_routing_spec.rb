require File.dirname(__FILE__) + '/../spec_helper'

describe SitesController do
  describe "route generation" do
 
    it "should map { :controller => 'sites', :action => 'index', :user_id => 1 } to user/1/sites" do
      route_for(:controller => "sites", :action => "index", :user_id => 1).should == "/users/1/sites"
    end
  
    it "should map { :controller => 'sites', :action => 'new', :user_id => 1 } to /users/1/sites/new" do
      route_for(:controller => "sites", :action => "new", :user_id => 1).should == "/users/1/sites/new"
    end
  
    it "should map { :controller => 'sites', :action => 'show', :id => 1, :user_id => 1 } to /users/1/sites/1" do
      route_for(:controller => "sites", :action => "show", :id => 1, :user_id => 1).should == "/users/1/sites/1"
    end
  
    it "should map { :controller => 'sites', :action => 'edit', :id => 1, :user_id => 1 } to /users/1/sites/1/edit" do
      route_for(:controller => "sites", :action => "edit", :id => 1, :user_id => 1).should == "/users/1/sites/1/edit"
    end
  
    it "should map { :controller => 'sites', :action => 'update', :id => 1, :user_id => 1} to /users/1/sites/1" do
      route_for(:controller => "sites", :action => "update", :id => 1, :user_id => 1).should == "/users/1/sites/1"
    end
  
    it "should map { :controller => 'sites', :action => 'destroy', :id => 1, :user_id => 1} to /users/1/sites/1" do
      route_for(:controller => "sites", :action => "destroy", :id => 1, :user_id => 1).should == "/users/1/sites/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'sites', action => 'index', :user_id => '1' } from GET /users/1/sites" do
      params_from(:get, "/users/1/sites").should == {:controller => "sites", :action => "index", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'new', :user_id => '1' } from GET /users/1/sites/new" do
      params_from(:get, "/users/1/sites/new").should == {:controller => "sites", :action => "new", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'create', :user_id => '1' } from POST /users/1/sites" do
      params_from(:post, "/users/1/sites").should == {:controller => "sites", :action => "create", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'show', id => '1', :user_id => '1' } from GET /users/1/sites/1" do
      params_from(:get, "/users/1/sites/1").should == {:controller => "sites", :action => "show", :id => "1", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'edit', id => '1', :user_id => '1' } from GET /users/1/sites/1;edit" do
      params_from(:get, "/users/1/sites/1/edit").should == {:controller => "sites", :action => "edit", :id => "1", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'update', id => '1', :user_id => '1' } from PUT /users/1/sites/1" do
      params_from(:put, "/users/1/sites/1").should == {:controller => "sites", :action => "update", :id => "1", :user_id => '1'}
    end
  
    it "should generate params { :controller => 'sites', action => 'destroy', id => '1', :user_id => '1' } from DELETE /users/1/sites/1" do
      params_from(:delete, "/users/1/sites/1").should == {:controller => "sites", :action => "destroy", :id => "1", :user_id => '1'}
    end
  end
end