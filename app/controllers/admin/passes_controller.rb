
module Admin
class PassesController < ApplicationController
  
  include PassesHelper
  
  before_action :set_pass, only: [:show, :edit, :update, :destroy]
  
  # GET /passes
  # GET /passes.json
  def index
    authorize Pass
    @passes = Pass.all
  end

  # GET /passes/1
  # GET /passes/1.json
  def show
    authorize @pass
  end

  # GET /passes/new
  def new
    authorize Pass
    @pass = Pass.new
  end

  # GET /passes/1/edit
  def edit
    authorize @pass
  end

  # POST /passes
  # POST /passes.json
  def create
    authorize Pass
    @pass = Pass.new(pass_params)
    respond_to do |format|
      if @pass.save
        PassBuilderJob.perform_later @pass.id
        format.html { redirect_to [:admin, @pass], notice: 'Pass was successfully created.' }
        format.json { render :show, status: :created, location: @pass, :include => 'recipient' }
      else
        format.html { render :new }
        format.json { render json: @pass.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /passes/1
  # PATCH/PUT /passes/1.json
  def update
    authorize @pass
    respond_to do |format|
      if @pass.update(pass_params)
        format.html { redirect_to @pass, notice: 'Pass was successfully updated.' }
        format.json { render :show, status: :ok, location: @pass }
      else
        format.html { render :edit }
        format.json { render json: @pass.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /passes/1
  # DELETE /passes/1.json
  def destroy
    authorize @pass
    @pass.destroy
    respond_to do |format|
      format.html { redirect_to admin_passes_url, notice: 'Pass was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pass
      @pass = Pass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pass_params
      params.require(:pass).permit(:serialNumber, :expiration, :message, :account_id)
    end
    
    def fetch_params
      params.require([:pass_type_id, :serial_number])
    end
    
end # End Class
end # End Admin Module
