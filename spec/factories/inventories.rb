FactoryBot.define do
  factory :inventory do
    kind { Inventory.kinds.keys.sample }
    quantity { 0 }
    survivor
  end
end
