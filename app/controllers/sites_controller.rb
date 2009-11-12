class SitesController < ApplicationController

  before_filter :check_user
  
  def check_user
    login_required
    access_denied if params[:user_id].nil? || (params[:user_id].to_i != current_user.id)
  end

  # GET /sites
  # GET /sites.xml
  def index
    @sites = User.find(current_user.id).sites #Site.find(

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id], :conditions => ['user_id = ?', current_user.id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id], :conditions => ['user_id = ?', current_user.id])
  end

  # POST /sites
  # POST /sites.xml
  def create
    @site = Site.new(params[:site])
    @site.user_id = current_user.id
    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully added to your permissions list.'
        format.html { redirect_to(user_site_url(:id => @site, :user_id => current_user.id)) }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find(params[:id], :conditions => ['user_id = ?', current_user.id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(user_site_url(:id => @site, :user_id => current_user.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find(params[:id], :conditions => ['user_id = ?', current_user.id])
    @site.destroy

    flash[:notice] = 'Site was successfully removed from your permissions list.'

    respond_to do |format|
      format.html { redirect_to(user_sites_url(:user_id => current_user.id)) }
      format.xml  { head :ok }
    end
  end
end
