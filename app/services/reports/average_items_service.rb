class Reports::AverageItemsService < ApplicationService
  def call
    success(averages: averages)
  rescue => e
    failure(e.message)
  end

  private

  def survivors
    @survivors ||= Survivor.where(infected: false).includes(:inventories)
  end

  def survivor_count
    @survivor_count ||= survivors.size
  end

  def sums
    survivors
      .flat_map(&:inventories)
      .group_by(&:kind)
      .transform_values { |items| items.sum(&:quantity) }
  end

  def averages
    @averages ||= sums.transform_values { |sum| (sum.to_f / survivor_count).round(2) }
  end
end
