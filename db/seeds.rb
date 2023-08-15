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
Game.create(name: 'heggon', prefix: 'hg', title: 'Los Planos de Heggon', icon_url: 'hg-icon.png')

Tool.create(name: 'settings', title: 'Configuración de la partida', short_title: 'configuración', icon_url: 'bi bi-gear-fill', role: 'admin', active: true ).save(validate: false)
Tool.create(name: 'armies', title: 'Lista de ejércitos', short_title: 'ejércitos', icon_url: 'bi-shield-shaded', role: 'player',
  options_info: 'Formato JSON con los siguientes valores:

*hp* con los siguientes valores:
  * *icon* class de bootstrap-icons
  * *name*, string
  * *step*, integer. Cuántos "pasos" para el 100%, 20 nos da 5 pasos

*soldiers*, integer. Número de hombres para 100% de hp

*tags* con cada etiqueta con su **key** y valores:
  * *str*, integer, fuerza de combate
  * *icon* class de bootstrap-icons
  * *name*, string
  * *colour*, class de bootstrap

*attributes* con cada atributo con su **key** y valores:
  * **str**, integer, fuerza por cada paso
  * *icon* class de bootstrap-icons
  * *name*, string
  * *sort*, integer. Columna desde 0 hasta 9',
  active: true)
Tool.create(name: 'travel', title: 'Calculadora de Viaje', short_title: 'Viaje', icon_url: 'bi-signpost-split-fill', role: 'player',
  options_info: 'Formato JSON con los siguientes valores:

*sea* con los siguientes valores

  * *base*: integer (velocidad base)
  * *terrain* con **key** {**mod**: integer, **name**: string}
  * *obstacles* con **key** {**mod**: integer, **name**: string}
  * *army_speed* con **key** {**mod**: integer, **name**: string}
  * En cada categoría debe haber un item con **key** = **default** con **mod** = **0**

*land* con el mismo formato que **sea**

*size*, un array de arrays con pares [**tamaño**, **modificador**]. Ordenado de mayor a menor, el último mostrando "-99"

*speed* con pares de valores con **key** {**mod**: integer, **name**: string}
  * En cada categoría debe haber un item con **key** = **default** con **mod** = **0**',
  active: true )
Tool.create(name: 'factions', title: 'Lista de Facciones', short_title: 'Facciones', icon_url: 'bi-flag-fill', role: 'master',
  options_info: '',
  active: true )
Tool.create(name: 'users', title: 'Lista de Jugadores', short_title: 'Jugadores', icon_url: 'bi-person-fill', role: 'admin',
  options_info: '',
  active: true )
Tool.create(name: 'locations', title: 'Lista de Lugares', short_title: 'Viaje', icon_url: 'bi-pin-map-fill', role: 'master',
  options_info: 'Array de etiquetas, no olvides incluir los corchetes **[** y **]** ni las comillas dobles **"**',
  active: true )
Tool.create(name: 'families', title: 'Lista de Familias', short_title: 'Familias', icon_url: 'bi-house-fill', role: 'master',
  options_info: 'Array de etiquetas, no olvides incluir los corchetes **[** y **]** ni las comillas dobles **"**',
  active: true )
Tool.create(name: 'map', title: 'Mapa', short_title: 'Mapa', icon_url: 'bi-globe-europe-africa', role: 'player',
  options_info: 'Formato JSON con los siguientes valores:

*img*, string. Nombre del archivo de la imagen base

*font*, string. Nombre de la 'font-family'. Debe definirse en el CSS

*zoom*, array con zoom mínimo y máximo

*scale*, integer, tamaño de los hexágonos

*bounds*, array con los límites del mapa. [[x0,y0],[x100,y100]]

*layers* cada capa un nuevo item con **key** y valores:
  * *name*, string
  * *types*, array. *keys* de los tipos de lugar en esta capa. Provenientes de la lista de lugares.

*attribution*, string. Copyright del mapa',
  active: true )

if Rails.env.development?
  User.create([
  {
  player: "hammer_ortiz", faction: Faction.find(3), discourse_id: 1, avatar_url: "https://www.valar.es/uploads/default/original/2X/0/0132d58e921e50a5b73524d077340de35693ad8b.png"
  }
  ])
end
