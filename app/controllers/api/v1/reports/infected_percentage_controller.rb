class Api::V1::Reports::InfectedPercentageController < ApplicationController
  def index
    result = ::Reports::InfectedPercentageService.call

    if result.success?
      @data = result.data
      render :infected_percentage, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
