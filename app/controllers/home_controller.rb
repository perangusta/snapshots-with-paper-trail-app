class HomeController < ApplicationController
  def index
    @projects_summary_completed     = Project.summary(scope: :completed)
    @projects_summary_draft         = Project.summary(scope: :draft)
    @negotiations_summary_completed = Negotiation.summary(scope: :completed)
    @negotiations_summary_draft     = Negotiation.summary(scope: :draft)

    @versions = PaperTrail::Version.all
  end
end
