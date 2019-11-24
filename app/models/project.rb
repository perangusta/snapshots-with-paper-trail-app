class Project < ApplicationRecord
  TAGS = %w[blue green red orange white black].freeze

  enum state: STATES

  has_many :negotiations, dependent: :destroy

  # Versioning
  include Versionable
  configure_paper_trail

  # Summary method
  include Summarizable

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 3 }
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true
  validates :start_on, presence: true
  validates :end_on, presence: true

  scope :ordered_by_updated_at, -> { order(updated_at: :desc) }

  scope :with_negotiations_summary, ->(negotiations_collection: nil, select_attributes: nil) {
    negotiations_collection ||= Negotiation.all
    select_attributes       ||= column_names

    attributes_list = select_attributes.map { |attribute| "#{table_name}.#{attribute}" }.join(', ')

    select_statement = <<~SQL.squish
      #{attributes_list}, 
      COUNT(negotiations.baseline) AS negotiations_count, 
      SUM(negotiations.baseline) AS negotiations_baseline, 
      SUM(negotiations.savings) AS negotiations_savings
    SQL

    left_outer_joins(:negotiations).merge(negotiations_collection).select(select_statement).group(attributes_list)
  }

  def to_s
    name
  end

  def tags=(values)
    super(Array(values).reject!(&:blank?))
  end
end
