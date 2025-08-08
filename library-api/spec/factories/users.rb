FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "member" }

    trait :librarian do
      role { "librarian" }
    end

    trait :member do
      role { "member" }
    end
  end
end
