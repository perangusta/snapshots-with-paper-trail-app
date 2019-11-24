class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :set_snapshot_at

  def info_for_paper_trail
    { ip: request.remote_ip, user_agent: request.user_agent }
  end

  def set_snapshot_at
    @snapshot_at = params[:snapshot_at].present? ? Date.parse(params[:snapshot_at]) : Date.current
  end

  def apply_filters(collection)
    if @snapshot_at < Date.current
      collection.snapshot_at(@snapshot_at)
    else
      collection
    end
  end
end
