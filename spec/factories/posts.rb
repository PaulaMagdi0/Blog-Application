FactoryBot.define do
  factory :post do
    title { "Sample Post" }
    tags { "tag1 tag2" }
    body { "This is the post body." }
    association :user
  end
end
