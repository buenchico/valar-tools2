class DamageSimulator
  def self.simulate_damage(units:, damage:, times:)
    new(units: units, damage: damage, times: times).call
  end

  def initialize(units:, damage:, times:)
    @units = units
    @damage = damage
    @times = times
  end

  def call
    if @times > 1
      simulate_damage_distribution
    else
      calculate_damage
    end
  end

private
  def simulate_damage_distribution
    # Build unit data
    units_by_army = @units.each_with_object(Hash.new { |h, k| h[k] = {} }) do |unit, hash|
      army_id = unit.army_id || 0

      hash[army_id][unit.id] = {
        unit_type: unit.unit_type,
        hp: unit.hp,
        count: unit.count,
        men: unit.men
      }
    end

    # Add summary stats
    units_by_army["total"] = {
      "damage": @damage,
      "attempts": @times
    }

    # Step 1: Initialize flat array
    attempt_logs = []

    # Step 2: Collect all unit records across attempts
    @times.times do |attempt_index|
      formatted_log = calculate_damage
      formatted_log.each do |unit_id, data|
        attempt_logs << data.merge(attempt: attempt_index)
      end
    end

    # Step 3: Final JSON structure
    full_log = {
      unit_data: units_by_army,
      attempt_logs: attempt_logs
    }

    # Step 4: Write to file
    File.open("logfile.txt", "w") do |file|
      file.puts JSON.pretty_generate(full_log)
    end
  end

  def calculate_damage
    units = @units.select { |u| u.hp > 0 }
    # Track simulated HP per unit by ID
    simulated_hp = units.index_with(&:hp).transform_keys(&:id)
    unit_lookup = units.index_by(&:id)

    remaining_damage = @damage
    damage_log = Hash.new { |h, k| h[k] = 0 }

    while remaining_damage > 0 && simulated_hp.any?
      eligible_units = simulated_hp.select do |unit_id, hp|
        unit = unit_lookup[unit_id]
        chunk = unit.hp_per_unit || 1
        unit && hp >= chunk && remaining_damage >= chunk
      end

      break if eligible_units.empty?

      # Weight units by number of chunks they can absorb
      weighted_units = {}
      eligible_units.each do |unit_id, hp|
        unit = unit_lookup[unit_id]
        next unless unit

        chunk = unit.hp_per_unit || 1
        next if chunk <= 0

        weighted_units[unit_id] = hp / chunk
      end

      total_weight = weighted_units.values.sum
      target = rand(total_weight)

      selected_unit_id = nil
      weighted_units.each do |unit_id, weight|
        target -= weight
        if target < 0
          selected_unit_id = unit_id
          break
        end
      end

      next unless selected_unit_id

      unit = unit_lookup[selected_unit_id]
      chunk = unit.hp_per_unit || 1

      simulated_hp[selected_unit_id] -= chunk
      remaining_damage -= chunk
      damage_log[selected_unit_id] += chunk
    end

    # Format and sort result
    formatted_log = damage_log.to_h do |unit_id, damage|
      unit = unit_lookup[unit_id]
      [
        unit_id,
        {
          army_id: unit&.army&.id || 0,
          unit_id: unit.id,
          unit_type: unit.unit_type,
          damage: damage,
          unit_losses: (damage / unit.hp_per_unit),
          unit_survivors: (unit.count - (damage / unit.hp_per_unit))
        }
      ]
    end

    return formatted_log
  end
end
