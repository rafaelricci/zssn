json.requester do
  json.id @requester.id
  json.inventory do
    Inventory.kinds.keys.each do |kind|
      json.set! kind, @requester.inventories.find_by(kind: kind)&.quantity || 0
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
