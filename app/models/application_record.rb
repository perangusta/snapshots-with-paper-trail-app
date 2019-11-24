class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  STATES = {
    draft:     1,
    completed: 2,
    deleted:   3
  }.freeze
end
