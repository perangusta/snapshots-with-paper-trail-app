class Project < ApplicationRecord
  enum state: STATES

  has_many :negotiations, dependent: :destroy

  # Versioning
  include Versionable
  configure_paper_trail

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 3 }
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true
  validates :start_on, presence: true
  validates :end_on, presence: true

  scope :ordered_by_updated_at, -> { order(updated_at: :desc) }

  scope :with_negotiations_summary, -> {
    select_statement = <<~SQL.squish
      projects.*, 
      COUNT(negotiations.baseline) AS negotiations_count, 
      SUM(negotiations.baseline) AS negotiations_baseline, 
      SUM(negotiations.savings) AS negotiations_savings
    SQL

    left_outer_joins(:negotiations).select(select_statement).group('projects.id')
  }

  def to_s
    name
  end
end
