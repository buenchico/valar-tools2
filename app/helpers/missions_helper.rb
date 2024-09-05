module MissionsHelper
  def factors_to_text(factors,style)
    if style == 'html'
      open = '<u>'
      close = '</u>'
    elsif style == 'markdown'
      open = '[u]'
      close = '[/u]'
    else
      open = ''
      close = ''
    end

    list = []

    factors&.each do |key, factors|
      case key.to_s
      when "double_plus"
        factors&.each do |factor|
          list.push(open + "◻️" + factor.capitalize + close)
        end
      when "plus"
        factors&.each do |factor|
          list.push("◻️" + factor.capitalize)
        end
      when "minus"
        factors&.each do |factor|
          list.push("◼️" + factor.capitalize)
        end
      when "double_minus"
        factors&.each do |factor|
          list.push(open + "◼️" + factor.capitalize + close)
        end
      end
    end

    list = list.join(", ")

    return list
  end
end
