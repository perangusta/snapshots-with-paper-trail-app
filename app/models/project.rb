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

  def to_s
    name
  end
end
