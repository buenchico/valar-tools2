module ArmiesHelper
  def total_army_units_by_type(armies)
    Array(armies).flat_map(&:units).group_by(&:unit_type).transform_values { |units| units.sum(&:count) }
  end
end
