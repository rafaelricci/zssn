class Api::V1::Reports::LostPointsController < ApplicationController
  def index
    result = ::Reports::LostPointsService.call

    if result.success?
      @data = result.data
      render :lost_points, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
