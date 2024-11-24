PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      any_word: true,
    },
    trigram: {
      threshold: 0.5
    }
  }
}
