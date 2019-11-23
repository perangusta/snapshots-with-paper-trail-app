class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.integer :state
      t.string :name
      t.text :description
      t.numeric :baseline
      t.numeric :savings
      t.date :start_on
      t.date :end_on

      t.timestamps
    end
  end
end
