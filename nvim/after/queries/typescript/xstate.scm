(
  (pair
    key: (property_identifier) @states_key
    value: (object
      (pair
        key: (_) @state_name-key
        value: (object
          (pair
            key: (property_identifier) @entry_key
            value: (_) @entry)?
          (pair
            key: (property_identifier) @on_key
            value: (object
              (pair
                key: (_) @event_key
                value: (object) @event)) @on)?
        ))))
  (#eq? @states_key "states")
  (#eq? @entry_key "entry")
  (#eq? @on_key "on")
)

