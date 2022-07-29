# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Faction.new(name: 'Admin').save(validate: false)
Faction.new(name: 'Master').save(validate: false)
Faction.new(name: 'Inactivo').save(validate: false)

User.create([
{
player: "valar", faction: Faction.find(1), discourse_id: 2, avatar_url: "https://www.valar.es/uploads/default/original/1X/7b48a9f0a39881e0f9fb5ee1f843617923d87cef.png"
}
])

Tool.new(name: 'settings', title: 'Configuración de la partida', short_title: 'configuración', icon_url: 'fas fa-tachometer-alt', role: 'admin', active: true ).save(validate: false)

if Rails.env.development?
  User.create([
  {
  player: "hammer_ortiz", faction: Faction.find(3), discourse_id: 1, avatar_url: "https://www.valar.es/uploads/default/original/2X/0/0132d58e921e50a5b73524d077340de35693ad8b.png"
  }
  ])
end
