class Api::V1::ReportsController < ApplicationController
  def infected_percentage
    result = ::Reports::InfectedPercentageService.call

    if result.success?
      @data = result.data
      render :infected_percentage, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def non_infected_percentage
    result = ::Reports::NonInfectedPercentageService.call

    if result.success?
      @data = result.data
      render :non_infected_percentage, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def average_items
    result = ::Reports::AverageItemsService.call

    if result.success?
      @data = result.data
      render :average_items, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def lost_points
    result = ::Reports::LostPointsService.call

    if result.success?
      @data = result.data
      render :lost_points, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
