class Negotiation < ApplicationRecord
  enum state: STATES

  belongs_to :project

  # Versioning
  include Versionable
  configure_paper_trail

  validates :name, presence: true
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true

  def to_s
    name
  end
end
