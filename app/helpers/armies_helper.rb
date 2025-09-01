module ArmiesHelper
  def total_army_strength(armies)
    armies&.sum(&:strength) || 0
  end

  def total_army_men(armies)
    armies&.sum(&:men) || 0
  end

  def total_army_men_start(armies)
    armies&.sum(&:men_start) || 0
  end

  def total_army_hp(armies)
    armies&.sum(&:hp) || 0
  end

  def total_army_units_by_type(armies)
    armies
      .flat_map(&:units)
      .group_by(&:unit_type)
      .transform_values do |units|
        {
          count: units.sum(&:count),
          strength: units.sum(&:strength)
        }
      end
  end
end
