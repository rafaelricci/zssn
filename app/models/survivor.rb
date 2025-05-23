class Survivor < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :infection_reports_given, class_name: "InfectionReport", foreign_key: :reporter_id, dependent: :destroy
  has_many :infection_reports, class_name: "InfectionReport", foreign_key: :reported_id, dependent: :destroy

  attribute :last_location, :st_point, srid: 4326, geographic: true
  enum :gender, [ :male, :female, :other ]

  validates :name, :age, :gender, :lat, :lon, presence: true

  before_validation :set_last_location
  after_create :initialize_inventory

  def inventory_itens
    inventories.each_with_object({}) do |inventory, hash|
      hash[inventory.kind.to_sym] = inventory.quantity
    end
  end

  private

  def initialize_inventory
    Inventory.kinds.keys.each do |kind|
      inventories.create!(kind: kind, quantity: 0)
    end
  end

  def set_last_location
    return unless lat.present? && lon.present?

    self.last_location = rgeo_factory.point(lon, lat)
  end

  def rgeo_factory
    @rgeo_factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
  end
end
