FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book Title #{n}" }
    sequence(:author) { |n| "Author #{n}" }
    sequence(:genre) { |n| "Genre #{n}" }
    sequence(:isbn) { |n| "978-#{n.to_s.rjust(10, '0')}" }
    total_copies { 5 }
    available_copies { 5 }

    trait :available do
      available_copies { 3 }
      total_copies { 5 }
    end

    trait :unavailable do
      available_copies { 0 }
      total_copies { 5 }
    end

    trait :fiction do
      genre { "Fiction" }
    end

    trait :science_fiction do
      genre { "Science Fiction" }
    end
  end
end
