# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem


  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '72d30fa75b0947232df5e4b541829b8a'
  
  
  
  def valid_access_key?
    #logger.debug "\n\nHTTP_REFERER: #{request.headers['HTTP_REFERER']}\n\n"
    sites = Site.find_by_access_key(params[:access_key])
    #logger.debug "\n\nkey: #{sites.to_yaml}\n\n"

    unless sites.length > 0
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
    unless http_referer_valid?(sites, request.headers['HTTP_REFERER'])
      render :file => "#{RAILS_ROOT}/public/500.html", :status => 500 and return
    end
    
  end
  
  def http_referer_valid?(sites, ref)
    # Return true if the the given key belongs to a user that have a site for the given HTTP_REFERER
    http_referer_found = ref.nil? #return true if there is no HTTP_REFERER
#    http_referer_found = true if RAILS_ENV == 'production' # DISABLE THIS FEATURE IN PRODUCTION UNTIL ALL USERS HAVE HAD A CHANCE TO UPDATE THEIR SITES
    return http_referer_found if http_referer_found == true
    
    sites.each do |s|
      return http_referer_found if http_referer_found == true
      http_referer_found = s.validate_http_referer(ref)
    end
    http_referer_found
  end
  
end
