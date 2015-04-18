Ext.define 'x_checkbox_group',
  alias: 'widget.x_checkbox_group'
  extend: 'x_radio_group'
  __createComponent: ()->
    @callParent ['Ext.form.CheckboxGroup']
  __setItems: ()->
    @callParent [@names]
    return
  isValid:()->
    return true unless @is_require

    empty = true
    val = @getValue()
    for prop of val
      empty = false

    ret = !empty
    unless ret 
      @markInvalid ''
    else
      @clearInvalid()
    ret
  initComponent: ->
    @callParent arguments
    for c in @query 'checkbox' then c.uncheckedValue = false