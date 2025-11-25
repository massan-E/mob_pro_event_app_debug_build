FactoryBot.define do
  factory :post do
    association :user
    sequence(:title) { |n| "Test Post #{n}" }
    content { "This is a sample post body." }
  end
end
