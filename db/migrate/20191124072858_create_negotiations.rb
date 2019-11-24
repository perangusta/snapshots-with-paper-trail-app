class CreateNegotiations < ActiveRecord::Migration[6.0]
  def change
    create_table :negotiations do |t|
      t.integer :state
      t.string :name
      t.numeric :baseline
      t.numeric :savings
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
