module Summarizable
  def self.included(base)
    base.class_eval do
      # Provide models with a summary method
      def self.summary(scope: :all)
        select_statement = <<~SQL
          COUNT(#{table_name}.id)                    AS records_count, 
          COALESCE(SUM(#{table_name}.baseline), 0.0) AS baseline_sum, 
          COALESCE(SUM(#{table_name}.savings),  0.0) AS savings_sum
        SQL

        public_send(scope).select(select_statement).to_a.first
      end
    end
  end
end
