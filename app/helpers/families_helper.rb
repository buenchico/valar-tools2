module FamiliesHelper
  def snippet_for_members(family, keyword)
    keyword_downcase = keyword.downcase
    members_downcase = family.members.downcase
    index = members_downcase.index(keyword_downcase)

    return nil if index.nil?

    # Find the start of the line containing the match
    start_line_index = family.members.rindex("\n", index) || 0
    start_index = [start_line_index, 0].max

    # Find the end of the line after the match
    end_line_index = family.members.index("\n", index)
    end_index = end_line_index || family.members.length

    # Extract the snippet
    snippet = family.members[start_index...end_index]

    return snippet
  end
end
