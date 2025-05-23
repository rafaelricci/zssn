class Inventory < ApplicationRecord
  belongs_to :survivor

  enum :kind, [ :water, :food, :medicine, :ammo ]

  validates :kind, presence: true, uniqueness: { scope: :survivor_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
