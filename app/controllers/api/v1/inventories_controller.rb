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
    {
      survivor_id: params.require(:survivor_id).to_i,
      kind: params.require(:kind),
      operation: params.require(:operation),
      quantity: params.require(:quantity)
    }
  end
end
