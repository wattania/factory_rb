//= require Xsk.form.FormatNumberField

Ext.define 'x_number',
  extend: 'Xsk.form.FormatNumberField'
  alias: 'widget.x_number'
  mixins:
    x_base: 'x_base'
  getSubmitData: ()->
    if @submitValue
      ret = {}
      ret[@name] = @getValue()
      ret
    else
      null

  setValue: (val)->
    @callParent arguments
    
  constructor: (config)->
    config.format = '0' if Ext.isEmpty config.format
    Ext.apply config,
      allowDecimals: config.format.indexOf('.') > -1
      decimalPrecision: 20

    @mixins.x_base.constructor.call @, config
    @callParent arguments

    @on 'render', ()->
      unless Ext.isEmpty @value
        @setFormatValue this.getValue()
