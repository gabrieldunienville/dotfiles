(
  (pair
    key: (property_identifier) @states-key
    value: (object
      (pair
        key: (_) @state-key
        value: (object
          (pair
            key: (property_identifier) @entry-key
            value: (_) @entry)
          (pair
            key: (property_identifier) @on-key
            value: (object
              (pair
                key: (_) @event-key
                value: (object) @event) @x) @on)
        ))))
  (#eq? @states-key "states")
  (#eq? @entry-key "entry")
  (#eq? @on-key "on")
)
