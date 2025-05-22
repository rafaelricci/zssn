class Survivor < ApplicationRecord
  attribute :last_location, :st_point, srid: 4326, geographic: true
  enum :gender, [ :male, :female, :other ]

  validates :name, :age, :gender, :lat, :lon, presence: true

  before_validation :set_last_location

  private

  def set_last_location
    return unless lat.present? && lon.present?

    self.last_location = rgeo_factory.point(lon, lat)
  end

  def rgeo_factory
    @rgeo_factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
  end
end
