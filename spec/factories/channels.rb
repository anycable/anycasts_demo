FactoryBot.define do
  factory :channel do
    name { Faker::Company.name }
  end
end