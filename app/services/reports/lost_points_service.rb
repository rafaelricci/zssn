class Reports::LostPointsService < ApplicationService
  def call
    success(lost_points: total)
  rescue => e
    failure(e.message)
  end

  private

  def item_point
    @item_point ||= {
      "water" => 4,
      "food" => 3,
      "medicine" => 2,
      "ammo" => 1
    }
  end

  def survivors_infected
    @survivors_infected ||= Survivor.where(infected: true).includes(:inventories)
  end

  def total
     survivors_infected.flat_map(&:inventories).sum { |inv| inv.quantity * item_point[inv.kind] }
  end
end
