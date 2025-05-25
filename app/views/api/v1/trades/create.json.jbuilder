json.receiver do
  json.id @receiver.id
  json.inventory do
    Inventory.kinds.keys.each do |kind|
      json.set! kind, @receiver.inventories.find_by(kind: kind)&.quantity || 0
    end
  end
end

json.offerer do
  json.id @offerer.id
  json.inventory do
    Inventory.kinds.keys.each do |kind|
      json.set! kind, @offerer.inventories.find_by(kind: kind)&.quantity || 0
    end
  end
end
