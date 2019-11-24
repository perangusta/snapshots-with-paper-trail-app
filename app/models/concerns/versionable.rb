module Versionable
  def self.included(base)
    base.class_eval do
      # Provide models with a common entry point for paper_trail
      def self.configure_paper_trail
        has_paper_trail meta: { item_name: :paper_trail_item_name }
      end
    end
  end

  def paper_trail_item_name
    to_s
  end
end
