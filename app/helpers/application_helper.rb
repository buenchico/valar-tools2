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
end
