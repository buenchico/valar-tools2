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
      factor = "◻️" + factor.downcase
    when "plus_double_once", "plus_double_multiple"
      factor = open + "◻️" + factor.downcase + close
    when "minus_simple_once", "minus_simple_multiple"
      factor = "◼️" + factor.downcase
    when "minus_double_once", "minus_double_multiple"
      factor = open + "◼️" + factor.downcase + close
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

  def replace_traits(text)
    @options["traits"].each do |trait, title|
      # Escaping asterisks in the regex and interpolating the trait
      text.gsub!(/\*\*(#{trait})\*\*/i) do |match|
        # Capitalize only the first letter of the matched trait
        capitalized = $1[0].upcase + $1[1..-1].downcase
        # Replace with the <abbr> tag while preserving the asterisks
        "**<abbr title='#{title}'>#{capitalized}</abbr>**"
      end
    end
    text.html_safe
  end
end
