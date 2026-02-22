; extends
; Inject Python highlighting for plugin config strings

; plugins
((plugin
  (string) @_plugin_name
  (string) @injection.content)
  (#match? @_plugin_name "^\"(beancount_reds_plugins|plugins)\\.")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "python"))

; fava extensions
((custom
  name: (string) @_directive_name
  (custom_value (string) @_extension_name)
  (custom_value (string) @injection.content))
  (#eq? @_directive_name "\"fava-extension\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "python"))
