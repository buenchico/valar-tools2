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

Game.create(name: 'valar', prefix: 'va', title: 'Valar Dohaeris', icon_url: 'va-icon.png')
Game.create(name: 'warvalar', prefix: 'wh', title: 'WarValar', icon_url: 'wh-icon.png')

Tool.create(name: 'settings', title: 'Configuración de la partida', short_title: 'configuración', icon_url: 'bi bi-gear-fill', role: 'admin', active: true ).save(validate: false)
Tool.create(name: 'armies', title: 'Lista de ejércitos', short_title: 'ejércitos', icon_url: 'bi-shield-shaded', role: 'player',
  options_info: 'Formato JSON con los siguientes valores:

  * *attributes* como pares **name**: **value**

  * *tags* con pares de valores para **icon**, **str** y **name**
  * No olvidar los *{* *}* ni las *"* (comillas dobles, no simples)',
  active: true)
Tool.create(name: 'travel', title: 'Calculadora de Viaje', short_title: 'Viaje', icon_url: 'bi-signpost-split-fill', role: 'player',
  options_info: '',
  active: true )
Tool.create(name: 'factions', title: 'Lista de Facciones', short_title: 'Facciones', icon_url: 'bi-flag-fill', role: 'master',
  options_info: '',
  active: true )
Tool.create(name: 'locations', title: 'Lista de Lugares', short_title: 'Viaje', icon_url: 'bi-pin-map-fill', role: 'master',
  options_info: 'Array de etiquetas, no olvides incluir los corchetes **[** y **]** ni las comillas dobles **"**',
  active: true )
Tool.create(name: 'families', title: 'Lista de Familias', short_title: 'Familias', icon_url: 'bi-house-fill', role: 'master',
  options_info: 'Array de etiquetas, no olvides incluir los corchetes **[** y **]** ni las comillas dobles **"**',
  active: true )
Tool.create(name: 'map', title: 'Mapa', short_title: 'Mapa', icon_url: 'bi-globe-europe-africa', role: 'player',
  options_info: '',
  active: true )

GameTool.where(tool_id: Tool.find_by(name: 'armies').id, game_id: Game.find_by(name: 'valar')).first.update(options: {
  "tags": {
    "cavalry": {
      "str": 2,
      "icon": "chess-knight-fill",
      "name": "caballería"
    },
    "garrison": {
      "str": 0,
      "icon": "chess-rook-fill",
      "name": "guarnición"
    },
    "peaseants": {
      "str": -2,
      "icon": "chess-pawn-fill",
      "name": "campesinos"
    }
  },
  "attributes": {
    "xp": {
      "str": 2,
      "icon": "chevron-double-up",
      "name": "veterano"
    },
    "armour": {
      "str": 1,
      "icon": "shield-fill",
      "name": "armadura"
    }
  }
})

if Rails.env.development?
  User.create([
  {
  player: "hammer_ortiz", faction: Faction.find(3), discourse_id: 1, avatar_url: "https://www.valar.es/uploads/default/original/2X/0/0132d58e921e50a5b73524d077340de35693ad8b.png"
  }
  ])
end
