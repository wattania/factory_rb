Ext.define 'FormHelper',
  statics:
    layout: (aConfig)->
      config = Ext.valueFrom aConfig, {}
      config.items = [] unless Ext.isArray aConfig.items

      formConfig = 
        xtype: 'form'
        bodyPadding: 10
        items: []

      unless Ext.isEmpty aConfig.name
        Ext.apply formConfig,
          name: aConfig.name
      
      row_span = 0
      col_span = 0

      config.items.sort (a, b)->
        pos_a = Ext.valueFrom a.pos, [1, 1]
        pos_b = Ext.valueFrom b.pos, [1, 1]
        
        return -1 if pos_a[0] < pos_b[0]
        return 1  if pos_a[0] > pos_b[0]
        return -1 if pos_a[1] < pos_b[1]
        return 1  if pos_a[1] > pos_b[1]

      FormHelper.genFormSimpleLayoutTable config, formConfig

    mark_tab_parent_invalid: (tabparent, value)->
      if value 
        unless Ext.isEmpty tabparent
          if Ext.isEmpty tabparent.invalid_title
            tabparent.invalid_title = tabparent.title  
            tabparent.setTitle tabparent.invalid_title + "<i class=\"fa fa-exclamation-circle tab-invalid\"></i>"
   
      else 
        unless Ext.isEmpty tabparent
          unless Ext.isEmpty tabparent.invalid_title
            tabparent.setTitle tabparent.invalid_title
            tabparent.invalid_title = null
            
      return

    get_report_filter: (form)->
      filter_config = {}
      values = form.getValues() 
      for prop, value of values
        if (!Ext.isEmpty value) or (value == false)
          form.getForm().getFields().each (item)->
            if item.name == prop
              filter_config[prop] = {} if Ext.isEmpty filter_config[prop]
              if Ext.isEmpty filter_config[prop].caption
                filter_config[prop].caption = ProgramManager.getLang
                  captions: Ext.valueFrom item.initialConfig.captions, []

              if Ext.isEmpty filter_config[prop].caption
                unless Ext.isEmpty item.boxLabel
                  filter_config[prop].caption = item.boxLabel

              filter_config[prop].value = value

      filter_config


    genFormSimpleLayoutTable: (config, formConfig)->
      totalRow = Ext.valueFrom config.row, 1
      totalCol = Ext.valueFrom config.col, 5

      _tmp_items = Ext.valueFrom config.items, []

      items = []
      hidden_items = Ext.Array.filter _tmp_items, (item)->
        if item.xtype in ['hidden', 'hiddenfield']
          return true
        else if item.type in ['hidden']
          return true
        else
          pos = Ext.valueFrom item.pos, [0, 0]
          pos_row = pos[0]
          pos_col = pos[1]
          if (pos_row == 0) and (pos_col == 0)
            return true
          else
            return false
        false

      for row_number in [1..totalRow] by 1
        for col_number in [1..totalCol] by 1
          _items = Ext.Array.filter _tmp_items, (item)->
            pos = Ext.valueFrom item.pos, [-1, -1]
            pos_row = pos[0] 
            pos_col = pos[1] 

            if (pos_row == row_number) and (pos_col == col_number)
              true
            else
              false 

          if _items.length > 0
            pos_item = (totalCol * row_number) - (totalCol + 1) + col_number
            items[pos_item] = _items[0]

      reserved_pos = []
      for i in [0..(totalRow - 1)] by 1
        reserved_pos[i] = []
        for j in [0..(totalCol - 1)] by 1
          reserved_pos[i][j] = null

      for eachItem, index in Ext.Array.clone items
        row_index = Math.floor index / totalCol
        col_index = index % totalCol

        unless Ext.isEmpty eachItem
          row_span    = Ext.valueFrom eachItem.row_span, 1
          col_span    = Ext.valueFrom eachItem.col_span, 1
           
          for i in [0..(row_span - 1)] by 1
            for j in [0..(col_span - 1)] by 1
              reserved_pos[row_index + i] = [] unless Ext.isArray reserved_pos[row_index + i]
              reserved_pos[row_index + i][col_index + j] = true

      Ext.apply formConfig,
        bodyPadding: 10
        border: false
        layout: 
          type: 'table'
          columns: totalCol
          tdAttrs: 
            valign: 'top'
    
        height: (totalRow * FORM_LINE_HEIGHT) + formConfig.bodyPadding

      for cmp, index in items
        panel = 
            padding: '0 20 0 0'
            layout: {type: 'vbox', align: 'stretch'}
            totalCol: totalCol
            border: false
            width_ratio: 1 / totalCol
            rowspan: 1
            colspan: 1
            height: FORM_LINE_HEIGHT
            width: 50
            items: []
        #debugger
        row_index = Math.floor index / totalCol
        col_index = index % totalCol 
        if Ext.isEmpty reserved_pos[row_index][col_index]
          formConfig.items.push panel
        else
          unless Ext.isEmpty cmp
            cmp_config  = FormHelper.__item cmp
            row_span    = Ext.valueFrom cmp_config.row_span, 1
            col_span    = Ext.valueFrom cmp_config.col_span, 1
            pos         = Ext.valueFrom cmp.pos, [1, 1]
            
            if row_span > 1
              Ext.apply panel,
                layout: 'fit'

            Ext.apply panel,
              height: FORM_LINE_HEIGHT * row_span
              rowspan: row_span
              colspan: col_span
              width_ratio: col_span / totalCol
              items: [cmp_config]
              
            if Ext.isObject cmp_config.panel 
              Ext.apply panel, cmp_config.panel

            formConfig.items.push panel
      
      Ext.apply formConfig,
        listeners:
          resize: (cmp)-> 
            width = cmp.getWidth() - 20
            cmp.suspendEvents()
            cmp.items.each (item)-> 
              unless item.xtype in ['hidden', 'hiddenfield', 'form']
                w = width * (Ext.valueFrom item.width_ratio, 0)
                item.setWidth w
            cmp.resumeEvents()
      
      Ext.Array.insert formConfig.items, formConfig.items.length, hidden_items
      if Ext.isObject config.config
        Ext.apply formConfig, config.config
      
      formConfig

    __item: (cmp)->
      cmpConfig = {}
      Ext.apply cmpConfig,
        convertToUpperCase: cmp.to_upper_case
      
      _type = Ext.valueFrom cmp.type, ''
      switch _type
        when 'text'
          cmpConfig.xtype = 'x_text'
          cmpConfig.height = 42

          if cmp.mask_re?
            cmpConfig.maskRe = cmp.mask_re

          if cmp.format?
            cmpConfig.xtype = 'x_format_text'
          else
            row_span = Ext.valueFrom cmp.row_span, 1
            if row_span > 1
              cmpConfig.xtype = 'x_textarea'
              cmpConfig.height = 42 * row_span

        when 'number'
          cmpConfig.xtype = 'x_number'
        when 'date'
          cmpConfig.xtype = 'x_date'
        when 'date_range'
          cmpConfig.xtype = 'x_date_range'
        when 'lookup', 'small_lookup_with_desc'
          cmpConfig.xtype = 'x_lookup'
          cmpConfig.lookup_type = Ext.valueFrom cmp.type, 'lookup' 
        when 'radio_group'
          cmpConfig.xtype = 'x_radio_group'
        when 'checkbox_group'
          cmpConfig.xtype = 'x_checkbox_group'
        when 'checkbox'
          cmpConfig.xtype = 'x_checkbox'
        when 'address'
          cmpConfig.xtype = 'x_address'
        else
          cmpConfig.xtype = "x_#{cmp.type}"
          
      Ext.apply cmpConfig, cmp
      
      cmpConfig
    editVisibleInit: (form, action)->
      for cmp in form.query 'component[is_edit_in_' + action + '=false]'
        cmp.setDisabled true

      for cmp in form.query 'component[is_edit_in_' + action + '=true]'
        cmp.setDisabled false

      for cmp in form.query "component[is_visible_in_" + action + "=false]"
        cmp.setVisible false

      for cmp in form.query "component[is_visible_in_" + action + "=true]"
        cmp.setVisible true

      return
    processFromResponse: (response, form, aAction, cb)->
      if response.success 
        unless response.valid? 
          Ext.create('ErrorBox',{message: "โปรดระบุ result[:valid]"}).show()
          cb false, form, aAction if cb?
          return

        if response.valid
          cb true, form, aAction if cb?
        else
          form.getForm().clearInvalid() 

          error_comsumped = {}
          for prop of response.errors
            error_comsumped[prop] = response.errors[prop]
          for prop of response.errors
            for component in form.query('component[name="' + prop + '"]')
              unless component.xtype in ['hiddenfield', 'hidden']
                if Ext.isFunction component.markInvalid
                  error_comsumped[prop] = null
                  component.markInvalid response.errors[prop]
                else
                  console.log "--- no mark invalid ---> ", prop
                  console.log component
              
          show_validate_message = false
          for prop of error_comsumped
            show_validate_message = true unless error_comsumped[prop] == null

          if show_validate_message
            validate_message = ""
            for prop of error_comsumped 
              if error_comsumped[prop]?
                #unless prop == 'base'
                #  validate_message += ('</br>' + prop + "  ")
                #else
                validate_message += ('</br>' + '' + "  ")
                validate_message += "</br>"


                validate_message += '<i class="fa fa-caret-right"></i>&nbsp;' + error_comsumped[prop].join '</br><i class="fa fa-caret-right"></i>&nbsp;</br>'

            Ext.create('ErrorBox',{message: validate_message, width: 800}).show()

          cb false, form, aAction if Ext.isFunction cb
      else
        cb false, form, aAction if Ext.isFunction cb
        
      return