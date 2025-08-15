class String
  def pluralize_all_words(count = nil)
    split.map { |word| word.pluralize(count) }.join(' ')
  end
end
