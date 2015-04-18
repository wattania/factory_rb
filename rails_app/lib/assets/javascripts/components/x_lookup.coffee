Ext.define 'x_lookup',
  alias: 'widget.x_lookup'
  extend: 'Ext.panel.Panel'
  border: false
  mixins:
    x_base: 'x_base'
    field: 'Ext.form.field.Field'
  layout: { type: 'hbox', align: 'bottom' }
  allow_file_type: []
  value: null
  record: null
  constructor: (config)->
    @config = config
    config.no_label = true
    @mixins.x_base.constructor.call @, config
    @callParent [config]
    return

  getSubmitData: ()->  
    ret = {}
    ret[@name] = @getValue()
    ret
  getValue: ()->
    @text_data.getValue()
  isDirty: ()->
    @text_data.isDirty()
  isValid: ()->
    @text_data.isValid()
  initComponent: ->
    me = @
    @rest_client = Ext.create 'RestClient', { url: 'lookup/customer_info' }
    @btn_clear = Ext.create 'Ext.button.Button',
      text: text_fa_icon 'times', ''
      handler: ()->
        me.text_data.setValue null

    @btn_lookup = Ext.create 'Ext.button.Button',
      disabled: Ext.valueFrom @readOnly, false
      hidden: Ext.valueFrom @readOnly, false
      text: text_fa_icon 'search', ''
      handler: ()->
        init_view = {customer_id: me.text_data.getValue()}
        me.fireEvent 'before_show_lookup_window', me, init_view
        ProgHelper.get_lookup "Lookup", "customer_info", init_view, (result)->
          if result
            me.record = result
            me.text_data.setValue (result.get 'customer_id')
            me.fireEvent 'after_fetch_value', me, result.data
          else
            me.record = null
            me.fireEvent 'after_fetch_value', me, {}

        ,
          me.initialConfig.opts

    @text_data = Ext.create 'Ext.form.field.Text',
      fieldLabel: @baseSetLabel @initialConfig
      labelAlign: @labelAlign
      submitValue: false
      tabIndex: -1 
      readOnly: Ext.valueFrom @readOnly, false
      value: @value
      allowBlank: if @is_require then false else true
      flex: 1
      listeners:
        blur: (cmp)->
          cmp.setReadOnly true
          me.fireEvent 'blur', me
          if Ext.isEmpty cmp.getValue()
            me.fireEvent 'empty', me
            cmp.setReadOnly false unless Ext.valueFrom(me.readOnly, false)
          else
            me.btn_lookup.setDisabled true unless me.btn_lookup.disabled

            p = {customer_id: cmp.getValue()}
            me.fireEvent 'fetch_value', me, p
            me.rest_client.index 'get_customer', p,
              (res)-> 
                me.btn_lookup.setDisabled false unless Ext.valueFrom(me.readOnly, false)
                cmp.setReadOnly false unless Ext.valueFrom(me.readOnly, false)
                if res.success
                  if Ext.isObject res.data 
                    me.fireEvent 'after_fetch_value', me, res.data
                    me.text_data.setValue res.data["customer_id"]
                  else
                    me.text_data.setValue null
                    me.fireEvent 'after_fetch_value', me, {}
                else
                  cmp.setValue null  
                  me.fireEvent 'after_fetch_value', me, {}
                  me.fireEvent 'empty', me
            ,
              ()-> 
                me.btn_lookup.setDisabled false unless Ext.valueFrom(me.readOnly, false)
                cmp.setReadOnly false unless Ext.valueFrom(me.readOnly, false)
                cmp.setValue null
                me.fireEvent 'after_fetch_value', me, {}
                me.fireEvent 'empty', me
            ,
              async: false

    @items = [
      @text_data
    ,
      @btn_lookup 
    ]
    @callParent arguments