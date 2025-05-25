class Survivor < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :infection_reports_given, class_name: "InfectionReport", foreign_key: :reporter_id, dependent: :destroy
  has_many :infection_reports_received, class_name: "InfectionReport", foreign_key: :reported_id, dependent: :destroy

  enum :gender, [ :male, :female, :other ]

  validates :name, :age, :gender, :latitude, :longitude, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  before_update :cannot_be_modified_if_infected, :cannot_be_infected_if_non_have_infection_reports
  after_create :initialize_inventory

  private

  def initialize_inventory
    inventories.create!(
      Inventory.kinds.keys.map { |kind| { kind: kind, quantity: 0 } }
    )
  end

  def cannot_be_modified_if_infected
    if infected_was && !infected_changed?(from: false, to: true)
      errors.add(:base, "Infected survivor cannot be updated")
      throw :abort
    end
  end

  def cannot_be_infected_if_non_have_infection_reports
    return unless infected_changed?(from: false, to: true)

    reports_count = infection_reports_received.select(:reporter_id).distinct.count

    if reports_count < 3
      errors.add(:base, "Survivor must have at least 3 distinct infection reports to be infected")
      throw :abort
    end
  end
end
