class HomeController < ApplicationController
  def index
    project_collection     = apply_filters(Project.all)
    negotiation_collection = apply_filters(Negotiation.all)

    @projects_summary_completed     = project_collection.summary(scope: :completed)
    @projects_summary_draft         = project_collection.summary(scope: :draft)
    @negotiations_summary_completed = negotiation_collection.summary(scope: :completed)
    @negotiations_summary_draft     = negotiation_collection.summary(scope: :draft)

    @eac_summary_completed          = project_collection.eac_summary(negotiation_collection, scope: :completed)
    @eac_summary_draft              = project_collection.eac_summary(negotiation_collection, scope: :draft)

    @versions = PaperTrail::Version.all
  end
end
