class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  require_role 'global_admin', :for => [:index]

  before_filter :login_required, :only => [:update, :edit]

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
#      logger.debug "\n\ncurrent_user: \n#{current_user.to_yaml}\n\n"
      self.current_user= @user unless self.logged_in?
#      logger.debug "\n\ncurrent_user: \n#{current_user.to_yaml}\n\n"
#      logger.debug "\n\n@user: \n#{@user.to_yaml}\n\n"
      if @current_user.has_role?('global_admin')#login == 'global_admin'
        flash[:notice] = "User successfully created"
        redirect_to users_path
        return
      end
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default(access_keys_path)
    else
      render :action => 'new'
    end
  end
  
  def index
    @users = User.find(:all)
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    @user.update_attributes(params[:user])
    @user.save
    if @user.errors.empty?
      redirect_back_or_default(access_keys_path)
      flash[:notice] = "Update Complate!"
    else
      render(:action => 'edit')
    end
  end

end
