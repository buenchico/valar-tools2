module ApplicationHelper
  def safe_image_tag(source, options = {})
    if source.present?
      begin
        image_tag(source, options)
      rescue => e
        Rails.logger.error("Image loading failed: #{e.message}")
        image_tag('tools-circle.webp', options)
      end
    else
      image_tag('tools-circle.webp', options)
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
      # If the last letter doesn't indicate gender, check the YAML file
      word_genders = I18n.t('word_genders', default: {}) # Load word genders from the YAML file
      if word_genders.key?(word.downcase.to_sym)
        return word_genders[word.downcase.to_sym]
      else
        last_letter = word[-1].downcase

        # Check if the last letter indicates the gender
        if last_letter == 'a'
          return 'feminine'
        else
          return 'masculine' # default to masculine
        end
      end
    else
      return 'masculine' # Default to masculine when the locale is not 'es'
    end
  end

  def natural_sort_key(item)
    # Remove any HTML tags
    cleaned_item = item.gsub(/<\/?[^>]*>/, '')

    # Split the string into parts and extract numbers
    cleaned_item.split(', ').map do |part|
      # Match text and number separately
      if part.match(/(\D*)(\d+)/)
        [part.match(/(\D*)(\d+)/)[1].strip, part.match(/(\d+)/)[0].to_i]
      else
        [part.strip, 0] # Handle case with no number
      end
    end
  end
end
