class Api::V1::Reports::AverageItemsController < ApplicationController
  def index
    result = ::Reports::AverageItemsService.call

    if result.success?
      @data = result.data
      render :average_items, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
