module ArmiesHelper
  def total_strength(armies)
    armies.sum { |army| army.strength }.round(2)
  end

  def total_men(armies)
    armies.sum { |army| ( army.hp.to_i * @options["soldiers"].to_i / 100 ) }
  end
end
