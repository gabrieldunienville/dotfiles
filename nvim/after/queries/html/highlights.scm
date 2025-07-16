; ; Custom template variable highlighting
; (text) @text

; ; Match template expressions in {{ }}
; ((text) @template.variable
;  (#match? @template.variable "{{.*}}"))


; ((text) @injection.content
;  (#set! injection.language "jinja"))

(text) @injection.content
(#set! injection.language "jinja")
