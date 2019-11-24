class Project < ApplicationRecord
  TAGS = %w[blue green red orange white black].freeze

  STATUSES = {
    planned:   1,
    started:   2,
    completed: 3,
    cancelled: 4
  }.freeze

  enum state: STATES
  enum status: STATUSES, _prefix: true

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

  def self.eac_summary(negotiations_collection, scope: :all)
    sql_query = <<~SQL.squish
      WITH
        filtered_negotiations AS (#{negotiations_collection.public_send(scope).to_sql}),
        filtered_projects     AS (#{public_send(scope).to_sql}),
        computed_projects     AS (
          SELECT
            filtered_projects.id,
            CASE filtered_projects.status
              WHEN 1 THEN filtered_projects.baseline
              WHEN 2 THEN filtered_projects.baseline
              WHEN 3 THEN SUM(filtered_negotiations.baseline)
              WHEN 4 THEN 0.0
            END AS baseline,
            CASE filtered_projects.status
              WHEN 1 THEN filtered_projects.savings
              WHEN 2 THEN filtered_projects.savings
              WHEN 3 THEN SUM(filtered_negotiations.savings)
              WHEN 4 THEN 0.0
            END AS savings
          FROM filtered_projects
          LEFT JOIN filtered_negotiations ON filtered_negotiations.project_id = filtered_projects.id
          GROUP BY filtered_projects.id, filtered_projects.status, filtered_projects.baseline, filtered_projects.savings
        )
      SELECT
        COALESCE(
          SUM(computed_projects.baseline),
          0.0
        ) AS baseline,
        COALESCE(
          SUM(computed_projects.savings),
          0.0
        ) AS savings
      FROM computed_projects
    SQL

    raw_result = connection.exec_query(sql_query).first || {}

    {
      baseline: raw_result['baseline'].to_f,
      savings:  raw_result['savings'].to_f
    }
  end
end
