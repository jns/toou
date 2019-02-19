class Admin::LogsController < AdminController
  before_action :set_admin_log, only: [:show]

  # GET /admin/logs
  # GET /admin/logs.json
  def index
    authorize Log
    @admin_logs = policy_scope(Log).order(created_at: :desc)
  end

  # GET /admin/logs/1
  # GET /admin/logs/1.json
  def show
    authorize @log
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_log
      @log = policy_scope(Log).find(params[:id])
    end

end
