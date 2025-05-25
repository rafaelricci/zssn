class Api::V1::TradesController < ApplicationController
  def create
    result = ::Survivors::TradeService.call(**trade_params)

    if result.success?
      @receiver = Survivor.find(trade_params[:receiver_id])
      @offerer = Survivor.find(trade_params[:offerer_id])
      render :create, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def trade_params
    params.require(:trade).permit(
      :offerer_id,
      :receiver_id,
      offer_items: Inventory.kinds.keys,
      request_items: Inventory.kinds.keys
    ).to_h.symbolize_keys
  end
end
