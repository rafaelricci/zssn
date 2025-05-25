class Api::V1::InventoriesController < ApplicationController
  def update
    result = ::Inventories::UpdateQuantityService.call(**update_params)

    if result.success?
      @survivor = result.data.survivor

      render :update, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.require(:inventory).permit(:kind, :operation, :quantity)
        .to_h
        .merge(survivor_id: params[:survivor_id])
        .symbolize_keys
  end
end
