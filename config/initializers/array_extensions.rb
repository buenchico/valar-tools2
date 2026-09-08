class Array
  def weighted_tally
    ### Takes -AnyWord and reduce the count of AnyWord
    each_with_object(Hash.new(0)) do |tag, h|
      h[tag.delete_prefix("-")] += tag.start_with?("-") ? -1 : 1
    end
  end
end
