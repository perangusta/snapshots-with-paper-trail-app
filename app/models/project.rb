class Project < ApplicationRecord
  STATES = {
    draft:     1,
    completed: 2,
    deleted:   3
  }.freeze

  enum state: STATES

  # Versioning
  has_paper_trail meta: { item_name: :paper_trail_item_name }

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 3 }
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true
  validates :start_on, presence: true
  validates :end_on, presence: true

  def to_s
    name
  end

  def paper_trail_item_name
    to_s
  end
end
