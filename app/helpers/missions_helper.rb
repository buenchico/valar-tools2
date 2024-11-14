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

    list_plus = []
    list_minus = []

    factors&.each do |key, factors|
      case key.to_s
      when "plus_double"
        factors&.each do |factor|
          list_plus.push(open + "◻️" + factor.capitalize + close)
        end
      when "plus_simple"
        factors&.each do |factor|
          list_plus.push("◻️" + factor.capitalize)
        end
      when "minus_simple"
        factors&.each do |factor|
          list_minus.push("◼️" + factor.capitalize)
        end
      when "minus_double"
        factors&.each do |factor|
          list_minus.push(open + "◼️" + factor.capitalize + close)
        end
      end
    end

    list = (list_plus.sort_by { |item| item.gsub(/<\/?[^>]*>|\[\/?[^\]]*\]/, '') } + list_minus.sort_by { |item| item.gsub(/<\/?[^>]*>|\[\/?[^\]]*\]/, '') }).join(", ")


    return list
  end
end
