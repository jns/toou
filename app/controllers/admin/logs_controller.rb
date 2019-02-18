class Admin::LogsController < AdminController
  before_action :set_admin_log, only: [:show]

  # GET /admin/logs
  # GET /admin/logs.json
  def index
    @admin_logs = Log.all.order(created_at: :desc)
  end

  # GET /admin/logs/1
  # GET /admin/logs/1.json
  def show
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_log
      @admin_log = Admin::Log.find(params[:id])
    end

end
