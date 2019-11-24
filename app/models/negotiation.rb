class Negotiation < ApplicationRecord
  enum state: STATES

  belongs_to :project

  validates :name, presence: true
  validates :baseline, presence: true, numericality: true
  validates :savings, presence: true, numericality: true
end
