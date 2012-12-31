class ProjectsController < ApplicationController
  respond_to :html, :xml, :json

  before_filter :load_templates, :only => [:new, :create, :edit, :update]
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]

  # GET /projects/dashboard
  def dashboard
    @deployments = Deployment.find(:all, :limit => 10, :order => 'created_at DESC')
    respond_with(@deployments)
  end

  # GET /projects
  def index
    @projects = Project.find(:all, :order => 'name ASC')
    respond_with(@projects)
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    respond_with(@project)
  end

  # GET /projects/new
  def new
    @project = Project.new
    respond_with(@project) do |format|
      format.html do
        if load_clone_original
          @project.prepare_cloning(@original)
          render :action => 'clone'
        end
      end
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    respond_with @project
  end

  # POST /projects
  def create
    @project = Project.unscoped.where(params[:project]).first_or_create

    if load_clone_original
      action_to_render = 'clone'
    else
      action_to_render = 'new'
    end

    if @project
      @project.clone(@original) if load_clone_original
      @project.save

      flash[:notice] = 'Project was successfully created.'
      respond_with(@project, :location => @project)
    else
      respond_with(@project) do |format|
        format.html {render :action => action_to_render}
      end
    end
  end

  # PUT /projects/1
  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      respond_with(@project, :location => @project)
    else
      respond_with(@project)
    end
  end

  # DELETE /projects/1
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to projects_path, :notice => 'Project was successfully deleted.'
  end

private

  def load_templates
    @templates = ProjectConfiguration.templates.sort.collect do |key, val|
      [key.to_s.titleize, key.to_s]
    end

    @template_infos = ProjectConfiguration.templates.collect do |key, val|
      [key.to_s, val::DESC]
    end
  end

  def load_clone_original
    if params[:clone]
      @original = Project.unscoped.find(params[:clone])
    else
      false
    end
  end
end
