module LoginUserHelper
  
#  def logged_in_user
#    user_to_log_in if request.session[:user_id] = user_to_log_in.id
#  end
  
  def log_in_a_user(admin=false)
    @logged_in_user = user_to_log_in(admin)
    add_user_to_find(@logged_in_user)
    request.session[:user_id] = @logged_in_user.id
  end
  
  def user_to_log_in(admin=false)
    if admin
      u = mock_model(User, :login => 'global_admin', :id => 1)
      u.stub!(:has_role?).with('global_admin').and_return(true)
      u
    else
      u = mock_model(User, :login => 'paul', :id => 2)
      u.stub!(:has_role?).with('global_admin').and_return(false)
      u
    end
  end
  
  def add_user_to_find(user)
    User.stub!(:find).with(user.id).and_return(user)
  end
  
end
