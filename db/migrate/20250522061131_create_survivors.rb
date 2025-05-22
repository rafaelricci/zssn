class CreateSurvivors < ActiveRecord::Migration[8.0]
  def change
    create_table :survivors do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.integer :gender, null: false
      t.float :lat, null: false
      t.float :lon, null: false
      t.st_point :last_location, geographic: true, null: false
      t.index :last_location, using: :gist

      t.timestamps
    end
  end
end
