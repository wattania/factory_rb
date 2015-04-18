Ext.define 'x_radio_group',
  alias: 'widget.x_radio_group'
  extend: 'Ext.form.FieldContainer'
  mixins:
    x_base: 'x_base'
    field: 'Ext.form.field.Field'
  layout: 'fit'
  minHeight: FORM_LINE_HEIGHT
  showInvalid: false
  isDirty: ()-> @radiogroup.isDirty()
  isValid: ()-> 
    if @is_require
      value = @getValue()
      if Ext.isObject value
        total = 0
        for prop, v of value then total += 1

      if total <= 0  
        @markInvalid()
        return false 

    true
  __createComponent: (name)->
    @radiogroup = Ext.create name, @radioGroupConfig
  __setItems: (name)->
    for value, i in Ext.valueFrom @values, [] 
      default_value = @default_value
      if Ext.isArray @default_value
        default_value = @default_value[i]

      if Ext.isArray @unchecked_values
        unchecked_value = @unchecked_values[i]

      @radioGroupConfig.items.push
        boxLabel: Ext.valueFrom(@labels[i])
        name: (if Ext.isArray name then name[i] else name)
        inputValue: value
        uncheckedValue: unchecked_value
        checked: (if value == default_value then true else false)
    return
  constructor: (config)->
    @config = config
    config.no_label = true
    @mixins.x_base.constructor.call @, config
    @callParent [config]
    return
  clearInvalid:()->
    if @showInvalid
      @items.getAt(0).removeCls 'group-invalid'
      @showInvalid = false
    
  markInvalid:()->
    @showInvalid = true
    @items.getAt(0).addCls 'group-invalid'
  getSubmitData: ()->
    value = @radiogroup.getValue()
    value[@name]
  getValue: ()->
    @radiogroup.getValue()
  setReadOnly: (readonly)->
    @radiogroup.setDisabled readonly
  setValue: (val)->
    @radiogroup.setValue val
  initComponent: ()->
    me = @
    @radioGroupConfig = 
      xtype: 'radiogroup'
      config: @config
      items: []
      listeners:
        change: (cmp, new_value, old_value)->
          me.clearInvalid()
          me.fireEvent 'change', cmp, new_value, old_value

    if Ext.isEmpty @columns
      if @is_two_column
        @radioGroupConfig.columns = 2
        @radioGroupConfig.vertical = true
      else if @is_horizontal
        @radioGroupConfig.columns = @values.length
      else
        @radioGroupConfig.columns = 1
    else
      Ext.apply @radioGroupConfig,
        columns: @columns


    @__setItems @name
    @__createComponent 'Ext.form.RadioGroup'
    @items = [
      xtype: 'fieldset'
      title: @baseSetLabel @config
      items: [
        @radiogroup
      ]
    ]
    @callParent arguments
    return