# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Channel.insert_all([{name: "general"}, {name: "random"}])

Channel.pluck(:id) => [id_1, id_2]

Message.insert_all(
  [
    {content: "When will Ruby 3.1 come out?", author: "Vova", channel_id: id_1},
    {content: "Who knows :shrug:", author: "Matz", channel_id: id_1},
    {content: "Rails 7 :heart:", author: "Alice", channel_id: id_2},
    {content: "I'm still on 4.2 :(", author: "Bob", channel_id: id_2}
  ]
)
