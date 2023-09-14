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

  def word_gender(word)
    if I18n.locale == :es
      last_letter = word[-1].downcase

      # Check if the last letter indicates the gender
      if last_letter == 'a'
        return 'feminine'
      elsif last_letter == 'o'
        return 'masculine'
      else
        # If the last letter doesn't indicate gender, check the YAML file
        word_genders = I18n.t('word_genders', default: {}) # Load word genders from the YAML file
        if word_genders.key?(word)
          return word_genders[word]
        else
          return 'masculine' # Default to masculine when gender is not found
        end
      end
    else
      return 'masculine' # Default to masculine when the locale is not 'es'
    end
  end

end
