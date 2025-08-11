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
end
