class Api::V1::InventoriesController < ApplicationController
  def update
    inventory = ::Inventories::UpdateQuantityService.call(**update_params)
    @survivor = inventory.survivor

    render :update, status: :ok
  rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
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
