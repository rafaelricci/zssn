class Inventories::UpdateQuantityService < ApplicationService
  def call
    raise "Survivor is infected" if survivor.infected?

    case @operation
    when :add
      perform_addition
    when :remove
      perform_removal
    else
      raise "Invalid operation: #{@operation}"
    end

    success(inventory)
  rescue => e
    failure(e.message)
  end

  private

  def initialize(survivor_id:, kind:, operation:, quantity:)
    @survivor_id = survivor_id
    @kind = kind.to_s
    @operation = operation.to_sym
    @quantity = quantity.to_i
  end

  def perform_addition
    inventory.increment!(:quantity, @quantity)
  end

  def perform_removal
    raise "Cannot remove more than available" if inventory.quantity < @quantity
    inventory.decrement!(:quantity, @quantity)
  end

  def survivor
    @survivor ||= Survivor.find(@survivor_id)
  rescue ActiveRecord::RecordNotFound
    raise "Survivor not found: #{@survivor_id}"
  end

  def inventory
    @inventory ||= survivor.inventories.find_by!(kind: @kind)
  rescue ActiveRecord::RecordNotFound
    raise "Inventory item not found: #{@kind}"
  end
end
