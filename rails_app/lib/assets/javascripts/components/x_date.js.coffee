Ext.define 'x_date',
  extend: 'Ext.form.field.Date'
  alias: 'widget.x_date'
  mixins:
    x_base: 'x_base'
  setReadOnly: (bool)->
    @setDisabled bool
  constructor: (config)->

    Ext.apply config,
      format: 'd/m/Y'
      submitFormat: 'Y-m-d'

    #unless Ext.valueFrom config.is_all_day, false
     
    #  @disabledDays =  [0, 6]   
    #  @disabledDaysText = 'วันไม่ถูกต้อง หรือตรงกับวันหยุด'

    
    #  #@disabledDates = holidays
    #  @disabledDatesText = 'วันที่ ไม่ถูกต้อง หรือตรงกับวันหยุด'

    @mixins.x_base.constructor.call @, config
    @callParent [config]
  getSubmitData:()->
    ret = {}
    value = @getValue()
    unless Ext.isEmpty value
      value = Ext.Date.format value, 'Y-m-d'
    ret[@name] = value
    

    ret