class CreateSurvivors < ActiveRecord::Migration[8.0]
  def change
    create_table :survivors do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.integer :gender, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.boolean :infected, null: false, default: false

      t.timestamps
    end
  end
end
