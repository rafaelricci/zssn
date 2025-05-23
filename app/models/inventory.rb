class Inventory < ApplicationRecord
  belongs_to :survivor

  enum :kind, [ :water, :food, :medicine, :ammo ]

  validates :kind, presence: true, uniqueness: { scope: :survivor_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :survivor_cannot_be_infected

  private

  def survivor_cannot_be_infected
    return if survivor.nil?

    if survivor.infected?
      errors.add(:base, "Survivor is infected and cannot modify inventory.")
    end
  end
end
