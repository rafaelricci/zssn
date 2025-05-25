FactoryBot.define do
  factory :survivor do
    name { Faker::Name.name }
    age { Faker::Number.decimal_part(digits: 2) }
    gender { Survivor.genders.keys.sample.to_sym }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end
end
