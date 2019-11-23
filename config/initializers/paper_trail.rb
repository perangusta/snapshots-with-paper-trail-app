# Monkey patching to allow eager loading on whodunnit
# https://stackoverflow.com/a/55733160/10417979
# https://stackoverflow.com/a/55763969/10417979 (Rails 6)
module PaperTrail
  class Version < ::ActiveRecord::Base
    include PaperTrail::VersionConcern

    belongs_to :actor, class_name: 'User', foreign_key: :whodunnit, optional: true
  end
end
