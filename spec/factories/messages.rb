# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { Faker::Quote.matz }
    author { "some_user" }
    association :channel
  end
end
