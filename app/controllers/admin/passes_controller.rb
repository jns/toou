
module Admin
class PassesController < ApplicationController
  
  include PassesHelper
  
  # GET /passes
  # GET /passes.json
  def index
    @passes = Pass.all
  end

  # GET /passes/1
  # GET /passes/1.json
  def show
  end

  # GET /passes/passType/serialnumber
  def fetch
    passTypeId, serialNumber = fetch_params
    pass = Pass.find_by passTypeIdentifier: passTypeId, serialNumber: serialNumber
    if pass
      passFileName = passFileName(pass)
      if not File.exists?(passFileName)
        # Build pass on the fly
        PassBuilderJob.new().perform(pass.id)
        raise ActionController::BadRequest.new("Problem generating pass") unless File.exists?(passFileName)
      end
      logger.debug("sending #{passFileName}")
      send_file(passFileName, type: 'application/vnd.apple.pkpass', disposition: 'inline')
    else
      raise ActionController::RoutingError.new('Pass Not Found')
    end
  end

  # GET /passes/new
  def new
    @pass = Pass.new
  end

  # GET /passes/1/edit
  def edit
  end

  # POST /passes
  # POST /passes.json
  def create
    @pass = Pass.new(pass_params)
    respond_to do |format|
      if @pass.save
        PassBuilderJob.perform_later @pass.id
        format.html { redirect_to @pass, notice: 'Pass was successfully created.' }
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
    @pass.destroy
    respond_to do |format|
      format.html { redirect_to passes_url, notice: 'Pass was successfully destroyed.' }
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
    
end
end
