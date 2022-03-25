# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    name { Faker::Company.name }
    members { [] }

    trait :direct do
      kind { "direct" }
      name { Channel.direct_channel_name_for(*members) }
    end
  end
end
