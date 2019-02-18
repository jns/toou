
module Admin
class PassesController < AdminController
  
  include PassesHelper
  
  before_action :set_pass, only: [:show]
  
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


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pass
      @pass = Pass.find(params[:id])
    end


end # End Class
end # End Admin Module
