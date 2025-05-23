class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.integer :quantity, null: false
      t.integer :kind, null: false
      t.references :survivor, null: false, foreign_key: true
      t.index [ :survivor_id, :kind ], unique: true

      t.timestamps
    end
  end
end
