Ext.define 'x_base',
  constructor: (config)->
    @showErrorMesssageIcon = false
    unless Ext.valueFrom config.no_label, false
      #@height = FORM_LINE_HEIGHT - FORM_LINE_SPACE
      @fieldLabel = @baseSetLabel config if Ext.valueFrom config.show_label, true
    
    if Ext.isEmpty config.labelAlign
      @labelAlign = 'top' 
    else
      @labelAlign = config.labelAlign

    @labelSeparator = ''
    
    @value = config.default_value if config.default_value?
    return
  baseSetLabel: (config)->
    label =  ProgHelper.get_lang config
    
    rangeLabel = (config.xtype + "").split('_')
    if Ext.isArray rangeLabel
      if rangeLabel[rangeLabel.length - 1] == 'range'
        label += " " + ProgHelper.get_lang
          captions: ['(from - to)', '(จาก - ถึง)']

    if config.is_require
      label += " *" 
      @allowBlank = false
      
    label

  text_fa_spin_icon: (icon_name, text, cls)->
    "#{text} <i class=\"label-fa-spin-icon fa fa-#{icon_name} #{cls}\"></i>"

  set_spin_text: (bool)->

    return if Ext.isEmpty @labelEl
    
    if bool
      if Ext.isBoolean bool
        text = 'spinner' 
      else
        text = bool if Ext.isString bool

      @labelEl.update @text_fa_spin_icon text, @fieldLabel, 'fa-spin'
    else
      @labelEl.update @fieldLabel
      
  getSubmitData:()->
    ret = {}
    ret[@name] = @getValue()
    ret