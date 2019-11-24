class HomeController < ApplicationController
  def index
    @snapshot_at = params[:snapshot_at].present? ? Date.parse(params[:snapshot_at]) : Date.current

    project_collection     = Project.all
    negotiation_collection = Negotiation.all

    if @snapshot_at < Date.current
      project_collection     = project_collection.snapshot_at(@snapshot_at.to_time.end_of_day)
      negotiation_collection = negotiation_collection.snapshot_at(@snapshot_at.to_time.end_of_day)
    end

    @projects_summary_completed     = project_collection.summary(scope: :completed)
    @projects_summary_draft         = project_collection.summary(scope: :draft)
    @negotiations_summary_completed = negotiation_collection.summary(scope: :completed)
    @negotiations_summary_draft     = negotiation_collection.summary(scope: :draft)

    @versions = PaperTrail::Version.all
  end
end
