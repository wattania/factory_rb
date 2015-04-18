Ext.define 'x_date_range',
  alias: 'widget.x_date_range'
  extend: 'Ext.form.FieldContainer'
  mixins:
    x_base: 'x_base'
    field: 'Ext.form.field.Field'
  layout: 
    type: 'hbox'
    align: 'stretch'
  constructor: (config)->
    @config = config
    @mixins.x_base.constructor.call @, config
    @callParent [config]
  initComponent: ()->
    me = @ 
    cc = []
    for c in @captions
      cc.push c + " (From)"

    date_from_conf = 
      name: "#{@name}_from"
      captions: cc
      show_label: false
      flex: 1
      submitValue: false
      is_all_day: @config.is_all_day
      margin: '0 5 0 0'
      getSubmitData:()->
      listeners:
        blur: (cmp)->
          value = cmp.getValue()
          if Ext.isEmpty value
            me.dateTo.setMinValue null
          else
            me.dateTo.setMinValue value
          return

    cc = []
    for c in @captions
      cc.push c + " (To)"

    date_to_conf = 
      name: "#{@name}_to"
      captions: cc
      show_label: false
      submitValue: false
      flex: 1
      is_all_day: @config.is_all_day
      getSubmitData:()->
      listeners:
        blur: (cmp)->
          value = cmp.getValue()
          if Ext.isEmpty value
            me.dateFrom.setMaxValue null
          else
            me.dateFrom.setMaxValue value
          return 

    if Ext.isObject @value
      unless Ext.isEmpty @value['from']
        date_from_conf.value = @value['from']

      unless Ext.isEmpty @value['to']
        date_to_conf.value = @value['to']

    @dateFrom = Ext.create 'x_date', date_from_conf
    @dateFrom.on 'change', (cmp)->
      value = cmp.getValue()
      me.dateTo.suspendEvents()
      if Ext.isEmpty value
        me.dateTo.setMinValue null
      else
        me.dateTo.setMinValue value
      me.dateTo.resumeEvents()
      return

    @dateTo = Ext.create 'x_date', date_to_conf
    @dateTo.on 'change', (cmp)->
      value = cmp.getValue()
      me.dateFrom.suspendEvents()
      if Ext.isEmpty value
        me.dateFrom.setMaxValue null
      else
        me.dateFrom.setMaxValue value
      me.dateFrom.resumeEvents()
      return 
      

    @items = [
      @dateFrom
    ,
      @dateTo
    ]
    @callParent arguments
  setValue: (val)->
    if Ext.isObject val
      @dateFrom.setValue val["from"]  unless Ext.isEmpty val["from"]
      @dateTo.setValue val["to"]      unless Ext.isEmpty val["to"]
    return
  setInvalidMessage: (message)->
    if @labelEl?
      unless @showErrorMesssageIcon
        m = Ext.create 'Ext.panel.Panel',
          margin: '0 0 0 5'
          cls: 'fa fa-info-circle'
          #renderTo: @labelEl 
        #@labelEl.update "#{@fieldLabel}: <i class=\"fa fa-user\" />"
        @showErrorMesssageIcon = true
        
  isValid: ()->


    return false unless @dateFrom.isValid()
    return false unless @dateTo.isValid()

    dateFromValue = @dateFrom.getValue()
    dateToValue   = @dateTo.getValue()

    unless Ext.isEmpty dateFromValue
      unless Ext.isEmpty dateToValue
        if dateFromValue > dateToValue
          @setInvalidMessage "ssss"
          @dateFrom.markInvalid "Date From > To"
          @dateTo.markInvalid "Date From > To"

          return false
    
    true
  getValue: ()->
    r = @getSubmitData()
    r
  getSubmitData:()->

    ret = {}

    dateFromValue = @dateFrom.getValue()
    dateToValue   = @dateTo.getValue()

    ret[@name + "_from"] = Ext.Date.format dateFromValue, 'Y-m-d' unless Ext.isEmpty dateFromValue
    ret[@name + "_to"]   = Ext.Date.format dateToValue, 'Y-m-d'   unless Ext.isEmpty dateToValue

    ret