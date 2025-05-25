class Reports::InfectedPercentageService < ApplicationService
  def call
    return success(percentage: 0.0) if total_survivors.zero?

    success(percentage: percentage)
  rescue => e
    failure(e.message)
  end

  private 

  def total_survivors
    @total_survivors ||= Survivor.count
  end

  def infeted_survivors_count
    @infected_survivors ||= Survivor.where(infected: true).count
  end

  def percentage
    @percentage ||= ((infeted_survivors_count.to_f / total_survivors) * 100).round(2)
  end
end
