FactoryBot.define do
  factory :infection_report do
    association :reporter, factory: :survivor
    association :reported, factory: :survivor
  end
end
