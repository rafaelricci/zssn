FactoryBot.define do
  factory :survivor do
    name { Faker::Name.name }
    age { Faker::Number.decimal_part(digits: 2) }
    gender { :other }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
  end
end
