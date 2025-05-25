class CreateInfectionReports < ActiveRecord::Migration[8.0]
  def change
    create_table :infection_reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :survivors }
      t.references :reported, null: false, foreign_key: { to_table: :survivors }

      t.timestamps
    end
  end
end
