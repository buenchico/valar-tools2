# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Faction.new(name: 'Admin', active: false).save(validate: false)
Faction.new(name: 'Master', active: false).save(validate: false)
Faction.new(name: 'Inactivo', active: false).save(validate: false)

User.create([
{
player: "valar", faction: Faction.find(1), discourse_id: 2
}
])

Tool.new(name: 'settings', title: 'Configuración de la partida', short_title: 'configuración', icon_url: 'fas fa-tachometer-alt', master: true, active: true ).save(validate: false)
