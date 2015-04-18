Ext.define 'x_textarea',
  extend: 'Ext.form.field.TextArea'
  alias: 'widget.x_textarea'
  mixins:
    x_base: 'x_base'
  constructor: (config)->
    @mixins.x_base.constructor.call @, config
    @callParent [config]
  getSubmitData:()->

    ret = {}
    ret[@name] = @getValue()
    ret
