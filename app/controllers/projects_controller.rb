class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects.order_by([[:created_at, :desc]]).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.build(resource_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  def update
    if @project.update_attributes(resource_params)
      redirect_to @project, notice: 'Project was successfully updated'
    else
      render action: 'edit'
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy

    redirect_to projects_url
  end

  protected

  def find_project
    @project = current_user.projects.find(params[:id])
  end

  def resource_params
    params.require(:project).permit(:name, :tag_list, :money_budget, :time_budget)
  end
end
