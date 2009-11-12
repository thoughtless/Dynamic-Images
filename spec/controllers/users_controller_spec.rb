require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  def valid_user(admin=false)
    u = user_to_log_in(admin)
    add_user_to_find(u)
    u
  end
  
  describe "handling GET /users with admin logged in" do

    before(:each) do
      log_in_a_user(true)
      @valid_user = valid_user
      User.stub!(:find).with(:all).and_return([@logged_in_user, @valid_user]) 
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all users" do
      User.should_receive(:find).with(:all).and_return([@logged_in_user, @valid_user])
      do_get
    end
  
    it "should assign the found users for the view" do
      do_get
      assigns[:users].should == [@logged_in_user, @valid_user]
    end
  end
  
  describe "handling GET /users with non-admin logged in" do

    before(:each) do
      log_in_a_user(false)
      @valid_user = valid_user(true)
      User.stub!(:find).with(:all).and_return([@logged_in_user, @valid_user]) 
    end
    
    def do_get
      get :index
    end
    
    it "should not be successful" do
      do_get
      response.should_not be_success
    end

    it "should return 401" do
      do_get
      response.code.should == "401"
    end
  
    it "should not assign any users for the view" do
      do_get
      assigns[:users].should == nil
    end
    
  end
  
  describe "handling GET /users without being logged in" do

    before(:each) do
      @valid_user1 = valid_user(false)
      @valid_user2 = valid_user(true)
      User.stub!(:find).with(:all).and_return([@valid_user1, @valid_user2]) 
    end
    
    def do_get
      get :index
    end
    
    it "should not be successful" do
      do_get
      response.should_not be_success
    end

    it "should render new session template" do
      do_get
      response.should redirect_to(new_session_path)
    end
  
    it "should not assign any users for the view" do
      do_get
      assigns[:users].should == nil
    end
  
    it "should inform user that authorization is required" do
      do_get
      flash[:notice].should == 'Authorization required'
    end
    
  end

  describe "handling GET /users/new" do

    before(:each) do
      @user = mock_model(User)
      User.stub!(:new).and_return(@user)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new user" do
      User.should_receive(:new).and_return(@user)
      do_get
    end
  
    it "should not save the new user" do
      @user.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new user for the view" do
      do_get
      assigns[:user].should equal(@user)
    end
  end
  
  describe "handling GET /users/1/edit without being logged in" do
    before(:each) do
    end
  
    def do_get
      get :edit, :id => "1"
    end
    
    it "should not be successful" do
      do_get
      response.should_not be_success
    end

    it "should render new session template" do
      do_get
      response.should redirect_to(new_session_path)
    end
  
    it "should not assign any users for the view" do
      do_get
      assigns[:user].should == nil
    end
  
    it "should inform user that authorization is required" do
      do_get
      flash[:notice].should == 'Authorization required'
    end
  end
  
  
  describe "handling GET /users/1/edit when logged in as the user being edited" do

    before(:each) do
      log_in_a_user
    end
  
    def do_get
      get :edit, :id => @logged_in_user.id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the user requested" do
      User.should_receive(:find).and_return(@logged_in_user)
      do_get
    end
  
    it "should assign the found user for the view" do
      do_get
      assigns[:user].should equal(@logged_in_user)
    end
  end  
  
  describe "handling GET /users/1/edit when logged in as a user other than the one being edited" do

    before(:each) do
      log_in_a_user
      @user_to_edit = valid_user(true)
    end
  
    def do_get
      get :edit, :id => @user_to_edit.id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the logged in user, not the requested user" do
      User.should_receive(:find).with(@logged_in_user.id).and_return(@logged_in_user)
      do_get
    end
  
    it "should assign the logged in user for the view" do
      do_get
      assigns[:user].should equal(@logged_in_user)
    end
  end

  describe "handling POST /users without being logged in" do

    before(:each) do
      @access_key = mock_model(AccessKey)
      @user = user_to_log_in(false)
      @user.stub!(:access_keys).and_return([@access_key])
      User.stub!(:new).and_return(@user)
    end
    
    describe "with successful save" do
  
      def do_post
        @user.should_receive(:save).and_return(true)
        @user.errors.should_receive(:empty?).and_return(true)
        post(:create, :user => {:login => 'paul', 
                                :email => 'paul@domain.com', 
                                :password => 'password', 
                                :password_confirmation => 'password'})
      end
  
      it "should create a new user" do
        User.should_receive(:new).and_return(@user)
        do_post
      end

      it "should redirect to the new the user's access keys'" do
        do_post
        response.should redirect_to(access_keys_path)
      end
      
      it "should log in to the new user's account'" do
        do_post
        @current_user == @user
      end
    end
    
    describe "with failed save" do

      def do_post
        @user.should_receive(:save).and_return(false)
        @user.errors.should_receive(:empty?).and_return(false)
        post :create, :user => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
      it "should not log the user in" do
        do_post
        @current_user == :false
      end
      
    end
  end

  describe "handling POST /users with admin logged in" do

    before(:each) do
      log_in_a_user(true)
      
      @access_key = mock_model(AccessKey)
      @user = mock_model(User)
      @user.stub!(:access_keys).and_return([@access_key])
      User.stub!(:new).and_return(@user)
    end
    
    describe "with successful save" do
  
      def do_post
        @user.should_receive(:save).and_return(true)
        @user.errors.should_receive(:empty?).and_return(true)
        post(:create, :user => {:login => 'paul', 
                                :email => 'paul@domain.com', 
                                :password => 'password', 
                                :password_confirmation => 'password'})
      end
  
      it "should create a new user" do
        User.should_receive(:new).and_return(@user)
        do_post
      end

      it "should redirect to the users index" do
        do_post
        response.should redirect_to(users_path)
      end
      
      it "should keep the admin logged in" do
        do_post
        @current_user == @logged_in_user
      end
    end
    
    describe "with failed save" do

      def do_post
        @user.should_receive(:save).and_return(false)
        @user.errors.should_receive(:empty?).and_return(false)
        post :create, :user => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
      it "should not log the user in" do
        do_post
        @current_user == :false
      end
      
    end
  end

  
  describe "handling PUT /users/1" do

  describe "with non-admin logged in" do
      before(:each) do
        log_in_a_user(false)
      
      end
      
      describe "with successful update" do
        before(:each) do
          @logged_in_user.stub!(:update_attributes).and_return(true)
          @logged_in_user.stub!(:save).and_return(true)
          @logged_in_user.stub!(:errors).and_return([])
        end
  
        def do_put
          @logged_in_user.should_receive(:update_attributes).and_return(true)
          put :update, :id => @logged_in_user.id
        end
  
#        it "should find the site requested" do
#          User.should_receive(:find).with("1", :conditions => ['user_id = ?', @logged_in_user.id]).and_return(@site)
#          do_put
#        end
  
        it "should update the current user" do
          do_put
          assigns(:user).should equal(@logged_in_user)
        end
  
        it "should assign the current user for the view" do
          do_put
          assigns(:user).should equal(@logged_in_user)
        end
  
        it "should redirect to the access keys page" do
          do_put
          response.should redirect_to(access_keys_path)
        end
  
      end
      
      describe "with failed update" do
        before(:each) do
          @error = "I am an error"
          @logged_in_user.stub!(:update_attributes).and_return(false)
          @logged_in_user.stub!(:save).and_return(false)
          @logged_in_user.stub!(:errors).and_return([@error])
        end
  
        def do_put
          put :update, :id => @logged_in_user.id
        end
  
        it "should re-render 'edit'" do
          do_put
          response.should render_template('edit')
        end
  
      end
    end
  end
#
#  describe "handling DELETE /sites/1" do
#
#    before(:each) do
#      log_in_a_user
#      
#      @site = mock_model(Site, :destroy => true)
#      Site.stub!(:find).and_return(@site)
#    end
#  
#    def do_delete
#      delete :destroy, :id => "1", :user_id => @logged_in_user.id
#    end
#
#    it "should find the site requested" do
#      Site.should_receive(:find).with("1", :conditions => ['user_id = ?', @logged_in_user.id]).and_return(@site)
#      do_delete
#    end
#  
#    it "should call destroy on the found site" do
#      @site.should_receive(:destroy)
#      do_delete
#    end
#  
#    it "should redirect to the sites list" do
#      do_delete
#      response.should redirect_to(user_sites_url(:user_id => @logged_in_user.id))
#    end
#  end
end
