FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Time.current }
    due_date { 2.weeks.from_now }

    trait :overdue do
      borrowed_at { 3.weeks.ago }
      due_date { 1.week.ago }
      # Skip validation for overdue books in tests
      to_create { |instance| instance.save(validate: false) }
    end

    trait :due_today do
      borrowed_at { 1.week.ago }
      due_date { Date.current }
      # Skip validation for due today books in tests
      to_create { |instance| instance.save(validate: false) }
    end

    trait :returned do
      returned_at { Time.current }
    end

    trait :active do
      returned_at { nil }
    end
  end
end
