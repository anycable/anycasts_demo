# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Channel.insert_all([{name: "general"}, {name: "random"}])

Channel.pluck(:id) => [id_1, id_2]

User.create!(username: "vova89", password: "qwerty")
User.create!(username: "alice", password: "qwerty")
jack = User.create!(username: "jack", password: "qwerty")
sally = User.create!(username: "sally", password: "qwerty")

user_ids = User.pluck(:id)

Message.insert_all(
  [
    {content: "When will Ruby 3.1 come out?", user_id: user_ids.sample, channel_id: id_1},
    {content: "Who knows :shrug:", user_id: user_ids.sample, channel_id: id_1},
    {content: "Rails 7 :heart:", user_id: user_ids.sample, channel_id: id_2},
    {content: "I'm still on 4.2 :(", user_id: user_ids.sample, channel_id: id_2}
  ]
)

direct_channel = Channel.find_or_create_direct_for(jack, sally)
Message.insert_all(
  [
    {content: "Hey, how is it going?", user_id: jack.id, channel_id: direct_channel.id},
    {content: "I'm fine, just can't feel my hand...", user_id: sally.id, channel_id: direct_channel.id}
  ]
)

railsconf_channel = Channel.create!(name: "railsconf-2022")
railsconf_channel.messages.create!(content: "It's great to be back offline", user: sally)
