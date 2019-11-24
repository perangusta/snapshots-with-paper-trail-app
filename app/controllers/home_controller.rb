class HomeController < ApplicationController
  def index
    @versions = PaperTrail::Version.all
  end
end
