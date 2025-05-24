class Trade::PerformService < ApplicationService
  def call
    validate_trade!
    validate_inventory!(from, @offer)
    validate_inventory!(to, @request)

    ActiveRecord::Base.transaction do
      perform_trade(from, to, @offer)
      perform_trade(to, from, @request)
    end

    success(success: true)
  rescue => e
    failure(e.message)
  end

  private

  def initialize(from_id:, to_id:, offer:, request:)
    @from_id = from_id
    @to_id = to_id
    @offer = offer.symbolize_keys
    @request = request.symbolize_keys
  end

  def validate_trade!
    raise "Survivor cannot trade with themselves" if @from_id == @to_id
    raise "Survivor is infected" if from.infected? || to.infected?
    raise "Trade must be balanced (equal points on both sides)" unless balanced_trade?
  end


  def perform_trade(giver, receiver, items)
    items.each do |kind, quantity|
      giver_inventory = giver.inventories.find_by!(kind: kind)
      receiver_inventory = receiver.inventories.find_by!(kind: kind)

      giver_inventory.decrement!(:quantity, quantity)
      receiver_inventory.increment!(:quantity, quantity)
    end
  end

  def validate_inventory!(survivor, items)
    items.each do |kind, quantity|
      inventory = survivor.inventories.find_by(kind: kind)
      raise "Survivor #{survivor.id} does not have item #{kind}" unless inventory
      raise "Survivor #{survivor.id} does not have enough #{kind}" if inventory.quantity < quantity
    end
  end

  def balanced_trade?
    total_points(@offer) == total_points(@request)
  end

  def total_points(items)
    items.sum { |kind, quantity| point_value(kind) * quantity }
  end

  def point_value(kind)
    values = {
      water: 4,
      food: 3,
      medicine: 2,
      ammo: 1
    }

    raise "Invalid item kind: #{kind}" unless values.key?(kind)
    values[kind]
  end

  def from
    @from = Survivor.find(@from_id)
  end

  def to
    @to = Survivor.find(@to_id)
  end
end
