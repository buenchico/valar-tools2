module ArmiesHelper
  def total_army_strength(armies)
    armies&.sum(&:strength)
  end

  def total_army_men(armies)
    armies&.sum(&:men)
  end

  def total_army_men_start(armies)
    armies&.sum(&:men_start)
  end
end
