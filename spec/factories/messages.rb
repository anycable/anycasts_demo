# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { Faker::Quote.matz }
    association :user
    association :channel
  end
end
