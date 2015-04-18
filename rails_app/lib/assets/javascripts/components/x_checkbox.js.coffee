Ext.define 'x_checkbox',
  extend: 'Ext.form.field.Checkbox'
  alias: 'widget.x_checkbox'
  no_label: true
  mixins:
    x_base: 'x_base'
  constructor: (config)->
    Ext.apply config,
      #value: false
      uncheckedValue: false
      inputValue: true
      margin: '10 0 0 0'

    config.no_label = Ext.valueFrom config.no_label, true

    @boxLabel = @baseSetLabel config

    @checked = true if Ext.valueFrom config.default_value, false

    @mixins.x_base.constructor.call @, config
    @callParent [config]

