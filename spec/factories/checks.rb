FactoryBot.define do
  factory :check do
    checked_by { "123" }
    claim { build(:claim, :submitted) }
    trait :approved do
      result { :approved }
    end

    trait :rejected do
      result { :rejected }
    end
  end
end