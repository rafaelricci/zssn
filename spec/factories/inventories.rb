FactoryBot.define do
  factory :inventory do
    quantity { Faker::Number.decimal_part(digits: 2) }
    kind { Inventory.kinds.keys.sample.to_sym }
    survivor
  end
end
