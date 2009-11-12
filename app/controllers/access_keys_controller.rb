class AccessKeysController < ApplicationController
  before_filter :login_required
  def index
    @access_keys = current_user.access_keys
  end
  
end
