module ArmiesHelper
  def total_army_units_by_unit_type(units)
    units.group_by(&:unit_type)
         .transform_values do |grouped_units|

           count = grouped_units.sum { |u| u.count.to_i }
           first = grouped_units.first

           title = count == 1 ? first.simple_type_name : first.simple_type_name_plural

           {
             count: count,
             count_death: grouped_units.sum { |u| u.count_death.to_i },
             men: grouped_units.sum { |u| u.men.to_i },
             strength: grouped_units.sum { |u| u.strength.to_f },
             strength_indirect: grouped_units.sum { |u| u.strength_indirect.to_f },
             hp: grouped_units.sum { |u| u.hp.to_i },
             icon: first.icon,
             colour: first.colour,
             speed: grouped_units.map(&:speed).max,
             title: title,
             army_type: first.army_type,
             hide_name: first.hide_name
           }
         end
         .sort_by { |key, data| [data[:army_type], key] }
         .to_h
  end
end
