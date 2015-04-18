Ext.define 'x_text',
  extend: 'Ext.form.field.Text'
  alias: 'widget.x_text'
  mixins:
    x_base: 'x_base'
  constructor: (config)->

    if config.no_label
      @margin = '10 0 0 0'
      @height = 15

    #Ext.apply config,
    #  plugins: ['clearbutton']
      
    @mixins.x_base.constructor.call @, config
    @callParent [config]


