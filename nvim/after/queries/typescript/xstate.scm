; (
;   (pair
;     key: (property_identifier) @_states_slot
;     value: (object
;       (pair
;         key: (_) @state_key
;         value: (object
;           (pair
;             key: (property_identifier) @_on_slot
;             value: (object
;               (pair
;                 key: (_) @event_key
;                 value: (object) @event
;               )))
;         ))))
;   (#eq? @_states_slot "states")
;   (#eq? @_on_slot "on")
; )
((pair
  key: (property_identifier) @_states_slot
  value: (object
    (pair
      key: (_) @state_key
      value: (object
        (pair
          key: (property_identifier) @_on_slot
          value: (object
            (pair
              key: (_) @event_key
              value: (object) @event)))?
        (pair
          key: (property_identifier) @_entry_slot
          value: (_) @entry)?
        (pair
          key: (property_identifier) @_invoke_slot
          value: (object) @invoke)?))))
  (#eq? @_states_slot "states")
  (#eq? @_on_slot "on")
  (#eq? @_entry_slot "entry")
  (#eq? @_invoke_slot "invoke"))

; (
;   (pair
;     key: (property_identifier) @_states_slot
;     value: (object
;       (pair
;         key: (_) @state_key
;         value: (object
;           (pair
;             key: (property_identifier) @_on_slot
;             value: (object
;               (pair
;                 key: (_) @event_key
;                 value: (object
;                   (pair
;                     key: (_) @_actions_slot
;                     value: (array
;                       (call_expression
;                         function: (identifier) @action_func_name
;                         )+)) @actions
;                   (#set! gabe "was_here"))
;                 )))?
;         ))))
;   (#eq? @_states_slot "states")
;   ; (#eq? @_entry_slot "entry")
;   (#eq? @_on_slot "on")
;   (#eq? @_actions_slot "actions")
; )
; (call_expression
;   function: (identifier) @action_func_name)+) @actions) @event)
; (pair
;   key: (property_identifier) @_entry_slot
;   value: (_) @entry)?
