module RecipesHelper
  def factor_to_text(factor, type, mode)
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

    case type
    when "plus_simple_once", "plus_simple_multiple"
      factor = "◻️" + factor.capitalize
    when "plus_double_once", "plus_double_multiple"
      factor = open + "◻️" + factor.capitalize + close
    when "minus_simple_once", "minus_simple_multiple"
      factor = "◼️" + factor.capitalize
    when "minus_double_once", "minus_double_multiple"
      factor = open + "◼️" + factor.capitalize + close
    else
      # Handle unknown type gracefully if needed
      factor = factor.capitalize
    end

    return factor
  end

  def result_to_text(result, type)
    case type
    when "major"
      result = "🟰 " + result.capitalize
    when "minor"
      result = "➖ " + result.capitalize
    when "improvement"
      result = "➕ " + result.capitalize
    else
      result = result.capitaliza
    end

    return result
  end
end
