PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      any_word: true
    },
    trigram: {
      threshold: 0.5
    }
  },
  ranked_by: ":tsearch * 2.0 + :trigram"
}
