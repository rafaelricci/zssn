class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.integer :kind, null: false
      t.integer :quantity, null: false, default: 0
      t.references :survivor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
