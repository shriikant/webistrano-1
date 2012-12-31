class RecipesController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]

  # GET /recipes
  def index
    @recipes = Recipe.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @recipes.to_xml }
    end
  end

  # GET /recipes/1
  def show
    find_recipe_with_version

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @recipe.to_xml }
    end
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
    respond_with(@recipe)
  end

  # GET /recipes/1;edit
  def edit
    @recipe = find_recipe_with_version
    respond_with(@recipe)
  end

  # POST /recipes
  def create
    @recipe = Recipe.new(params[:recipe] || {})

    respond_to do |format|
      if @recipe.save
        flash[:notice] = 'Recipe was successfully created.'
        format.html { redirect_to recipe_url(@recipe) }
        format.xml  { head :created, :location => recipe_url(@recipe) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors.to_xml }
      end
    end
  end

  # PUT /recipes/1
  def update
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      if @recipe.update_attributes(params[:recipe] || {})
        flash[:notice] = 'Recipe was successfully updated.'
        format.html { redirect_to recipe_url(@recipe) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors.to_xml }
      end
    end
  end

  # DELETE /recipes/1
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:notice] = 'Recipe was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.xml  { head :ok }
    end
  end

  def preview
    @recipe = Recipe.new(:body => params[:recipe])
    respond_to do |format|
      format.html { 
        render :partial => "preview", :locals => {:recipe => @recipe}
      }
    end
  end

private

  def find_recipe_with_version
    @recipe = Recipe.find(params[:id])

    unless params[:version].blank?
      recipe_version = @recipe.find_version(params[:version])
      if recipe_version
        @recipe.version = recipe_version.version
        @recipe.name = recipe_version.name
        @recipe.description = recipe_version.description
        @recipe.body = recipe_version.body
      end
    end

    @recipe
  end
end
