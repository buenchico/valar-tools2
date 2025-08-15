class String
  IGNORE_WORDS = %w[the a of in on el la un uno una de].freeze

  def pluralize_all_words(count = nil)
    split.map do |word|
      IGNORE_WORDS.include?(word.downcase) ? word : word.pluralize(count)
    end.join(' ')
  end
end
