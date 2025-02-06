# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ruby_channel = Channel.create!(name: "ruby")
random_channel = Channel.create!(name: "random")
rails_channel = Channel.create!(name: "rubyonrails")

# some random users
User.create!(username: "vova89", password: "qwerty")
User.create!(username: "alice", password: "qwerty")
User.create!(username: "bob", password: "qwerty")

# user for direct channels
jack = User.create!(username: "jack", password: "qwerty")
sally = User.create!(username: "sally", password: "qwerty")
bart = User.create!(username: "bart", password: "qwerty")
homer = User.create!(username: "homer", password: "qwerty")

user_ids = User.pluck(:id)

Message.insert_all(
  [
    {content: "When is Ruby 4 coming?", user_id: user_ids.sample, channel_id: ruby_channel.id},
    {content: "Who knows :shrug:", user_id: user_ids.sample, channel_id: ruby_channel.id},
    {content: "If only Ruby 4 had method overloading...", user_id: user_ids.sample, channel_id: ruby_channel.id},
    {content: "And a proper pipe operator!", user_id: user_ids.sample, channel_id: ruby_channel.id},
    {content: "Rails 8 :heart:", user_id: user_ids.sample, channel_id: rails_channel.id},
    {content: "I'm still on 4.2 :(", user_id: user_ids.sample, channel_id: rails_channel.id},
    {content: "Random thought: pizza is just an open-faced sandwich", user_id: user_ids.sample, channel_id: random_channel.id},
    {content: "Mind = blown :exploding_head:", user_id: user_ids.sample, channel_id: random_channel.id},
    {content: "That's the most random thing I've read today", user_id: user_ids.sample, channel_id: random_channel.id}
  ]
)

direct_channel_1 = Channel.find_or_create_direct_for(jack, sally)
Message.insert_all(
  [
    {content: "Hey, how is it going?", user_id: jack.id, channel_id: direct_channel_1.id},
    {content: "I'm fine, just can't feel my hand...", user_id: sally.id, channel_id: direct_channel_1.id}
  ]
)

direct_channel_2 = Channel.find_or_create_direct_for(bart, homer)
Message.insert_all(
  [
    {content: "Eat my shorts!", user_id: bart.id, channel_id: direct_channel_2.id},
    {content: "D'oh!", user_id: homer.id, channel_id: direct_channel_2.id}
  ]
)
