class Api::V1::TradesController < ApplicationController
  def create
    result = ::Trade::PerformService.call(
      from_id: trade_params[:from_id],
      to_id: trade_params[:to_id],
      offer: trade_params[:offer].to_h,
      request: trade_params[:request].to_h
    )

    if result.success?
      @requester = Survivor.find(trade_params[:from_id])
      @offerer = Survivor.find(trade_params[:to_id])
      render :create, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def trade_params
    params.require(:trade).permit(
      :from_id,
      :to_id,
      offer: Inventory.kinds.keys,
      request: Inventory.kinds.keys
    )
  end
end
