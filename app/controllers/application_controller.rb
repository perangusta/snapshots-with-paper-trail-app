class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  def info_for_paper_trail
    { ip: request.remote_ip, user_agent: request.user_agent }
  end
end
