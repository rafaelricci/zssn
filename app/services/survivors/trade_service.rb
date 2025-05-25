class Survivors::TradeService < ApplicationService
  def call
    validate_trade!
    
    ActiveRecord::Base.transaction do
      execute_offerer_trade!
      execute_receiver_trade!
    end

    success("Trade completed successfully")
  rescue => e
    failure(e.message)
  end

  private

  def initialize(offerer_id:, receiver_id:, offer_items:, request_items:)
    @offerer = Survivor.find(offerer_id)
    @receiver = Survivor.find(receiver_id)
    @offer_items = offer_items.transform_keys(&:to_s)
    @request_items = request_items.transform_keys(&:to_s)
  end
  
  def points
    {
      'water' => 4,
      'food' => 3,
      'medicine' => 2,
      'ammo' => 1
    }
  end

  def validate_trade!
    raise "Cannot trade with yourself" if @offerer.id == @receiver.id
    raise "One or both survivors are infected" if @offerer.infected? || @receiver.infected?
    raise "Unfair trade. Point values must match" unless fair_trade?
  end

  def fair_trade?
    total_points(@offer_items) == total_points(@request_items)
  end

  def execute_offerer_trade!
    process_items(@offerer, @offer_items, :remove)
    process_items(@offerer, @request_items, :add)
  end

  def execute_receiver_trade!
    process_items(@receiver, @request_items, :remove)
    process_items(@receiver, @offer_items, :add)
  end

  def total_points(items)
    items.sum { |kind, qty| points[kind] * qty }
  end

  def process_items(survivor, items, operation)
    items.each do |kind, qty|
      result = Inventories::UpdateQuantityService.call(
        survivor_id: survivor.id,
        kind: kind,
        operation: operation,
        quantity: qty
      )

      raise result.error unless result.success?
    end
  end
end