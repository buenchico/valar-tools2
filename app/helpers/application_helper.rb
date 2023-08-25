module ApplicationHelper
  def number_to_modifier(number)
    if number.nil?
      "+0"
    elsif number >= 0
      "+#{number}"
    else
      "–#{number.abs}"
    end
  end

  def calculate_mod(value)
    if value == nil
      0
    elsif value == 0
      0
    elsif value >= 0
      if (1..2).include?(value)
        1
      elsif (3..5).include?(value)
        2
      elsif (6..9).include?(value)
        3
      elsif (10..14).include?(value)
        4
      else
        5
      end
    else
      if value == 0
        0
      elsif (-2..-1).include?(value)
        -1
      elsif (-5..-3).include?(value)
        -2
      elsif (-9..-6).include?(value)
        -3
      elsif (-14..-10).include?(value)
        -4
      else
        -5
      end
    end
  end
end
