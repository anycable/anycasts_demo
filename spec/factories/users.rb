# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user-#{n}" }
    password { "qwerty" }
  end
end
