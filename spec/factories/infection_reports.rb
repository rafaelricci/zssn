FactoryBot.define do
  factory :infection_report do
    reporter { create(:survivor) }
    reported { create(:survivor) }
  end
end
