class Reports::NonInfectedPercentageService < ApplicationService
  def call
    return success(percentage: 0.0) if survivors_count.zero?

    success(percentage: percentage)
  rescue => e
    failure(e.message)
  end

  private

  def survivors_count
    @survivors_count ||= Survivor.count
  end

  def survivors_non_infected_count
    @survivors_non_infected ||= Survivor.where(infected: false).count
  end

  def percentage
    @percentage ||= ((survivors_non_infected_count.to_f / survivors_count) * 100).round(2)
  end
end
