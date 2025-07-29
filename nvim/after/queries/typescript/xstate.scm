; Entry
((pair
  key: (property_identifier) @_states_slot
  value: (object
    (pair
      key: (_) @state_key
      value: (object
        (pair
          key: (property_identifier) @_entry_slot
          value: (_) @entry)))))
  (#eq? @_states_slot "states")
  (#eq? @_entry_slot "entry"))

; Invoke
((pair
  key: (property_identifier) @_states_slot
  value: (object
    (pair
      key: (_) @state_key
      value: (object
        (pair
          key: (property_identifier) @_invoke_slot
          value: (object) @invoke)))))
  (#eq? @_states_slot "states")
  (#eq? @_invoke_slot "invoke"))

; State Event
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
              value: (object) @event)))))))
  (#eq? @_states_slot "states")
  (#eq? @_on_slot "on"))

; Actor Scoped Event
((call_expression
  function: (member_expression
    property: (property_identifier) @_create_machine)
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @_on_slot
        value: (object
          (pair
            key: (_) @event_key
            value: (object) @event))))))
  (#eq? @_create_machine "createMachine")
  (#eq? @_on_slot "on"))
