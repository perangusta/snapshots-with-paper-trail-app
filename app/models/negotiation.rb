class Negotiation < ApplicationRecord
  enum state: STATES

  belongs_to :project, touch: true

  # Versioning
  include Versionable
  configure_paper_trail

  validates :name, presence: true
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true

  scope :ordered_by_updated_at, -> { order(updated_at: :desc) }

  def to_s
    name
  end
end
