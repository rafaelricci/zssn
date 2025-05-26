class Api::V1::Reports::NonInfectedPercentageController < ApplicationController
  def index
    result = ::Reports::NonInfectedPercentageService.call

    if result.success?
      @data = result.data
      render :non_infected_percentage, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
