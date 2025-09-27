module ArmiesHelper
  def total_army_units_by_unit_type(units)
    units.group_by(&:unit_type)
         .transform_values do |grouped_units|
           grouped_units
             .then do |sorted_units|
               {
                 count: sorted_units.sum { |u| u.count.to_i },
                 count_death: sorted_units.sum { |u| u.count_death.to_i },
                 men: sorted_units.sum { |u| u.men.to_i },
                 strength: sorted_units.sum { |u| u.strength.to_f },
                 strength_indirect: sorted_units.sum { |u| u.strength_indirect.to_f },
                 hp: sorted_units.sum { |u| u.hp.to_i },
                 icon: sorted_units.first.icon,
                 colour: sorted_units.first.colour,
                 speed: sorted_units.map(&:speed).max,
                 title: sorted_units.first.simple_type_name,
                 army_type: sorted_units.first.army_type
               }
             end
         end
         .sort_by { |key, data| [data[:army_type], key] }.to_h
         .to_h
  end
end
