class Inventories::UpdateQuantityService
  def self.call(survivor_id:, kind:, operation:, quantity:)
    new(survivor_id: survivor_id, kind: kind, operation: operation, quantity: quantity).call
  end

  def call
    raise "Invalid operation: #{@operation}" unless operations.key?(@operation)

    operations[@operation].call
    inventory
  end

  private

  def initialize(survivor_id:, kind:, operation:, quantity:)
    @survivor_id = survivor_id
    @kind = kind
    @operation = operation.to_sym
    @quantity = quantity.to_i
  end

   def operations
    {
      add: -> { perform_addition },
      remove: -> { perform_removal }
    }
  end

  def perform_addition
    inventory.increment!(:quantity, @quantity)
  end

  def perform_removal
    raise_if_removal_invalid!
    inventory.decrement!(:quantity, @quantity)
  end

  def raise_if_removal_invalid!
    raise "Survivor is infected" if survivor.infected?
    raise "Cannot remove more than available" if inventory.quantity < @quantity
  end

  def survivor
    @survivor = Survivor.find(@survivor_id)
  rescue ActiveRecord::RecordNotFound => e
    raise "Survivor not found: #{@survivor_id}"
  end

  def inventory
    @inventory = survivor.inventories.find_by!(kind: @kind)
  rescue ActiveRecord::RecordNotFound => e
    raise "Inventory item not found: #{@kind}"
  end
end
