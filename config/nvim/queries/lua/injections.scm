; extends
; Highlight the query string in `vim.treesitter.set_query`
((function_call
  name: [
    ; `vim.treesitter.set_query` or `treesitter.set_query`
    (dot_index_expression
      field: (_) @_function_name)
    ; `set_query`
    (_) @_function_name
  ]
  ; Third argument is the query
  arguments: (arguments (_) (_) (string content: _ @query))
  (#eq? @_function_name "set_query")))
