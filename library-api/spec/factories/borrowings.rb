FactoryBot.define do
  factory :borrowing do
    user { nil }
    book { nil }
    borrowed_at { "2025-08-08 10:47:57" }
    due_date { "2025-08-08 10:47:57" }
    returned_at { "2025-08-08 10:47:57" }
  end
end
