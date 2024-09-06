module MissionsHelper
  def factors_to_text(factors,mode)
    if mode == 'html'
      open = '<u>'
      close = '</u>'
    elsif mode == 'markdown'
      open = '[u]'
      close = '[/u]'
    else
      open = ''
      close = ''
    end

    list = []

    factors&.each do |key, factors|
      case key.to_s
      when "plus_double"
        factors&.each do |factor|
          list.push(open + "◻️" + factor.capitalize + close)
        end
      when "plus_simple"
        factors&.each do |factor|
          list.push("◻️" + factor.capitalize)
        end
      when "minus_simple"
        factors&.each do |factor|
          list.push("◼️" + factor.capitalize)
        end
      when "minus_double"
        factors&.each do |factor|
          list.push(open + "◼️" + factor.capitalize + close)
        end
      end
    end

    list = list.join(", ")

    return list
  end
end
