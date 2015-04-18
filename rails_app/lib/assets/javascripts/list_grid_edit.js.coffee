Ext.define 'ListGridEdit',
  __actionConfigFn: (actionButtonConf, aAction, self)->
      Ext.apply actionButtonConf,
        disabled: true
        action: aAction
        active_selected: true

      conf = @__getActionConfig aAction, self
      Ext.apply actionButtonConf, conf

      return
  __createGridAction: (aActions, gridConfig, self)->
    return unless Ext.isArray aActions

    me = @
    if aActions.length > 0
      if Ext.isArray gridConfig.dockedItems
        foundActionToolbar = false
        for tool in gridConfig.dockedItems
          if (tool.dock == 'top') and (tool.xtype == 'toolbar')
            foundActionToolbar = true 

        unless foundActionToolbar
          gridConfig.actions = []
          gridConfig.dockedItems.push
            xtype: 'toolbar'
            height: FORM_TOOLBAR_HEIGHT
            dock: 'top'
            name: 'actions'
            items: [] 

    for action in aActions

      actionButtonConf = 
        height: TOOLBAR_BUTTON_HEIGHT
        handler: (cmp)->
          cmp.setDisabled true
          grid = cmp.up('grid')
          me.__doAction grid, cmp.action, (result)->
            cmp.setDisabled false
            if result
              grid.getStore().load()
            me.__actionActiveCondition grid
            return

      if action in ['->']
        actionButton = action
      else
        if Ext.isArray action
          mainAction = null
          for _action, i in action
            actionButtonConf = 
              handler: (cmp)->
                cmp.setDisabled true
                me.__doAction cmp.up('grid'), cmp.action, ()->
                  cmp.setDisabled false
                  return
            
            @__actionConfigFn actionButtonConf, _action, self
            if i == 0
              actionButtonConf.sub_actions = [actionButtonConf]
              mainAction = Ext.create 'Ext.button.Button', actionButtonConf
            else
              mainAction.sub_actions.push actionButtonConf

          actionButton = mainAction 
        else
          @__actionConfigFn actionButtonConf, action, self
          actionButton = Ext.create 'Ext.button.Button', actionButtonConf

      actionButton.setVisible false unless Ext.valueFrom action.hidden, true

      for tool in gridConfig.dockedItems
        if tool.name == 'actions'
          tool.items.push actionButton
          gridConfig.actions.push actionButton

    totalActionButton = 0
    toolbar = null
    for tool in gridConfig.dockedItems
      if tool.name == 'actions'
        toolbar = tool
        for button in tool.items
          totalActionButton += 1 if button.isVisible()
    if totalActionButton == 0
      unless Ext.isEmpty toolbar
        toolbar.height = 0
        toolbar.visible = false

    return
  __getActionConfig: (aAction, self)->
    config = ActionConfig.select aAction, self
    if Ext.isFunction self.getActionConfig
      Ext.apply config, Ext.valueFrom (self.getActionConfig aAction), {}

    config
  __doAction: (grid, aAction, cb)->
    me = @
    action = @__getActionConfig aAction, self
    grid.setLoading action.text
    fn_action =(grid, aAction, cb)-> 
      if Ext.isFunction action.before_do_action
        action.before_do_action grid, (result, values)->
          if result
            me.___do_action grid, aAction, action, cb, values
          else
            cb result
      else
        me.___do_action grid, aAction, action, cb

      return

    if Ext.isEmpty action.confirm_msg_box
      fn_action grid, aAction, cb
    else
      msg_config = 
        title:    Ext.valueFrom action.confirm_msg_box.title, null
        msg:      Ext.valueFrom action.confirm_msg_box.msg, ""
        buttons:  Ext.valueFrom action.confirm_msg_box.buttons, Ext.Msg.OKCANCEL
        icon:     Ext.valueFrom action.confirm_msg_box.icon, Ext.Msg.QUESTION
        closable: Ext.valueFrom action.confirm_msg_box.closable, false
        fn: (btn)->
          if btn == 'ok'
            grid.setLoading action.text
            fn_action grid, aAction, cb
          else
            grid.setLoading false
            cb false
          return

      if Ext.isFunction action.confirm_msg_box.fn
        Ext.apply msg_config,
          fn: action.confirm_msg_box.fn

      grid.setLoading false
      Ext.Msg.show msg_config
        
    return
  __controlAction: (cmp, record)->
    unless Ext.valueFrom cmp.multi_selected, false
      disabled = Ext.valueFrom(record.get("set_action_#{cmp.action}_disabled"), false) 
      cmp.setDisabled disabled
    else 
      if Ext.valueFrom cmp.active_selected, false
        cmp.setDisabled Ext.valueFrom(record.get("set_action_#{cmp.action}_disabled"), false)
     
    return
  __actionActiveCondition: (grid)-> 
    me = @
    selections = grid.getSelectionModel().getSelection()
    grid.dockedItems.each (item)->
      if item.xtype == 'toolbar'
        item.items.each (cmp)->
          if Ext.isFunction cmp.setTooltip
            cmp.setTooltip '' unless cmp.name == 'reset_column'
              

          action_for_multi = Ext.valueFrom cmp.multi_selected, false
           
          if selections.length > 0
            if selections.length > 1
              
              if action_for_multi
                cmp.setDisabled false
              else
                cmp.setDisabled true
            
          if cmp.active_selected
            if selections.length > 1
              cmp.setDisabled true unless action_for_multi
            else if selections.length > 0
              cmp.setDisabled false  
            else
              cmp.setDisabled true

          if selections.length == 1
            me.__controlAction cmp, selections[0]
            
          # DISABLE ACTION FOR MULTISELECT WITH ACTION IS DISABLED BY CONFIG
          for record in selections
            if Ext.valueFrom record.get("set_action_#{cmp.action}_disabled"), false
              cmp.setDisabled true
              break

          for record in selections 
            desc = Ext.valueFrom record.get("set_action_#{cmp.action}_desc"), ""
            unless Ext.isEmpty desc
              if cmp.isDisabled()
                tooltip = []
                tooltip.push "<b>ไม่สามารถ (#{cmp.text}) ได้!</b></br>"
                tooltip.push "<ul>"
                tooltip.push "</br><li>" + text_fa_icon('arrow-circle-o-right', desc)+ "</li>"
                tooltip.push "</ul>"
                cmp.setTooltip tooltip.join('')  
              else
                cmp.setTooltip ''

             
      return
    return
  __set_default_columns: (listColumn)->
    foundId = false
    found_lock_version = false

    for colField in listColumn.fields
      if Ext.isObject colField
        foundId = true if colField.name == 'id'
        found_lock_version = true if colField.name == 'lock_version'
          
      else
        foundId = true if colField == 'id'
        found_lock_version = true if colField == 'lock_version'
          
     
    listColumn.fields.push {name: 'id'} unless foundId
    listColumn.fields.push {name: 'lock_version'} unless found_lock_version

    if Ext.isArray listColumn.actions 
      for action in listColumn.actions
        unless action in ['->']
          if Ext.isArray action
            listColumn.fields.push 
              type: 'string'
              name: 'select_action'
              defaultValue: ''

            action_ctrl_list = []
            for action_name in action
              action_ctrl_list.push 
                type: 'boolean'
                name: "set_action_#{action_name}_disabled"
                defaultValue: false
              ,
                type: 'boolean'
                name: "set_action_#{action_name}_visible"
                defaultValue: true
              ,
                type: 'string'
                name: "set_action_#{action_name}_desc"
                defaultValue: ""

            Ext.Array.insert listColumn.fields, 0, action_ctrl_list

          else
            Ext.Array.insert listColumn.fields, 0, [
              type: 'boolean'
              name: "set_action_#{action}_disabled"
              defaultValue: false
            ,
              type: 'boolean'
              name: "set_action_#{action}_visible"
              defaultValue: true
            ,
              type: 'string'
              name: "set_action_#{action}_desc"
              defaultValue: ""
            ]

    listColumn
  create_grid_list: (self, a_url)->
    me = @

    columnConfig = null
    if Ext.isFunction self.getListColumnLayout
      columnConfig = GridHelper.layout self.getListColumnLayout()
    else if Ext.isFunction self.getListColumn
      columnConfig = self.getListColumn()
 
    return null if Ext.isEmpty columnConfig

    listColumn = @__set_default_columns columnConfig

    store_config =
      fields: listColumn.fields
 
    if (Ext.valueFrom listColumn.enquiry, false) and (Ext.isArray listColumn.columns)
      if listColumn.columns.length > 0
        rest_client = @restClient
        rest_client = @rest_client if Ext.isEmpty rest_client

        GridHelper.init_column_config rest_client, listColumn, store_config, @name

    unless Ext.isEmpty a_url
      Ext.apply store_config,
        remoteSort: true
        proxy:
          type: 'ajax'
          url: a_url
          extraParams:
            method: 'list'
          reader:
            type: 'json'
            rootProperty: 'rows'
            totalProperty: 'total'
          listeners:
            exception: (request, result)->
              try
                response = Ext.JSON.decode result.responseText 
                unless response.success
                  Ext.create('ErrorBox',
                    message: response.message
                    backtrace: response.backtrace
                    ).show()
              catch e
                Ext.Msg.alert '', result.responseText

        autoLoad: false
        listeners: 
          beforeload: (store, options)->
            if Ext.isFunction self.before_list_load
              self.before_list_load store, options

            true
          load: (store, records, success)->
            grid = store.grid_list
            unless Ext.isEmpty grid
              grid.dockedItems.each (item)->
                if item.xtype == 'toolbar'
                  item.items.each (cmp)->
                    if Ext.isFunction cmp.setTooltip  
                      cmp.setTooltip '' unless cmp.name == 'reset_column'
                    return
                return

            no_lock_version = false
            for record in records
              no_lock_version = true if Ext.isEmpty record.get 'lock_version'
            
            if no_lock_version
              Ext.Msg.alert 'Error!!!!', 'ไม่มี Lock Version สำหรับบางรายการหรือทั้งหมด!</br>ถ้าทำงานต่อจะผิดพลาดทันที กรุณาแจ้ง Administrator !'
            
            return

      unless Ext.valueFrom(columnConfig.paging, true)
        Ext.apply store_config.proxy,
          limitParam: null
          pageParam: null
          startParam: null
          noCache: false

    if Ext.isFunction @before_create_store
      @before_create_store store_config

    store = Ext.create 'Ext.data.Store', store_config
           
    gridConfig =
      enableColumnHide: true
      enableColumnMove: true
      region: 'center'
      width:  '100%'
      height: '100%'
      x: 0
      y: 0
      fields: listColumn.fields
      flex: 1
      border: 1
      paging: Ext.valueFrom columnConfig.paging, true
      multi: Ext.valueFrom columnConfig.multi, false
      columns: listColumn.columns
      store: store
      dockedItems: []
      listeners: 
        itemdblclick: (view, record)->
          grid = @
          selections = @getSelectionModel().getSelection()
          
          if selections.length == 1
            if record in selections
              actionFound = false
              @dockedItems.each (item)->
                if (item.dock == 'top') and (item.xtype == 'toolbar')
                  item.items.each (cmp)->
                    if cmp.handle_dbl_click
                      unless cmp.isDisabled()
                        unless actionFound
                          actionFound = true
                          me.__doAction grid, cmp.action, ()->
                            #grid.setLoading false
                            return
                    return
                return
          return
        selectionchange: (selectionmodel, models)-> 
          selections = @getSelectionModel().getSelection()
          if selections.length == 0
            @dockedItems.each (item)->
              if item.xtype == 'toolbar'
                item.items.each (cmp, index)->
                  cmp.setDisabled true if cmp.active_selected
                  return
              return
          else if selections.length > 1
            found_action = false
            @dockedItems.each (item)->
              if item.xtype == 'toolbar'
                item.items.each (cmp, index)->
                  sub_actions = Ext.valueFrom cmp.sub_actions, []
                  for action in sub_actions
                    if Ext.valueFrom action.multi_selected, false
                      unless found_action
                        new_button = Ext.create 'Ext.button.Button', action
                        new_button.setDisabled false
                        item.remove cmp
                        item.insert index, new_button
                        new_button.sub_actions = sub_actions
                        found_action = true

                  if cmp.active_selected and cmp.handle_dbl_click
                    cmp.setDisabled true
              return

          else
            if selections.length > 0
              @dockedItems.each (item)->
                if item.xtype == 'toolbar'
                  item.items.each (cmp, button_index)->
                    if Ext.isArray cmp.sub_actions
                      record = selections[0]
                      all_select_actions = (record.get("select_action") + "").split("|")
                      
                      for select_action in all_select_actions
                        if Ext.isString select_action
                          unless Ext.isEmpty select_action
                            selectActions = select_action.split(",")
                             
                            if selectActions.length > 0
                              index = parseInt selectActions[0]
                               
                              unless isNaN index
                                if button_index == index
                                  for sub in cmp.sub_actions
                                    if sub.action == selectActions[1]
                                      newButton = Ext.create 'Ext.button.Button', sub
                                      newButton.setDisabled false
                                      item.remove cmp
                                      item.insert index, newButton

                                      newButton.sub_actions = cmp.sub_actions unless newButton.sub_actions?
                    return
                return

          me.__actionActiveCondition @
 
          return

    if !Ext.isEmpty(a_url) and Ext.valueFrom(gridConfig.paging, true)

      gridConfig.dockedItems.push 
        xtype: 'pagingtoolbar'
        dock: 'bottom'
        displayInfo: true
        store: store 

    if Ext.isBoolean(gridConfig.multi) and gridConfig.multi
      Ext.apply gridConfig,
        selModel: Ext.create 'Ext.selection.CheckboxModel', {}
    else if gridConfig.multi
      Ext.apply gridConfig,
        selModel: gridConfig.multi
    
    me.__createGridAction listColumn.actions, gridConfig, self
    
    if (Ext.valueFrom columnConfig.enquiry, false ) and (listColumn.columns.length > 0)
      for docked in Ext.valueFrom gridConfig.dockedItems, []
        if (docked.dock == 'top') and (docked.xtype == 'toolbar')
          if Ext.isArray docked.items
            docked.items.push '->'
            docked.items.push 
              xtype: 'button'
              name: 'reset_column'
              text: button_icon_reset ''
              tooltip: 'Reset Column to Default.'
              cls: 'filter-toolbar-button'
              handler: (cmp)->
                rest_client = self.restClient
                rest_client = self.rest_client if Ext.isEmpty rest_client

                return if Ext.isEmpty rest_client

                cmp.setDisabled true
                win = Ext.Msg.progress '', 'Resetting ...', ''

                cmp.setDisabled true
                rest_client.create 'reset_columns', {program: self.name},
                  (response)->
                    if response.success
                      grid = cmp.up('grid')
                      grid.suspendEvents()
 
                      new_column_orders = []
                      
                      win.updateProgress 0.3, 'Width, Show'
                      for column in grid.query 'gridcolumn' 
                        unless Ext.isEmpty column.initialConfig.ori_width
                          column.setWidth Ext.valueFrom(column.initialConfig.ori_width, 100)

                        if Ext.valueFrom column.initialConfig.mark_hidden, false
                          column.show()

                      win.updateProgress 0.3, 'Move Column '
                      is_new_order =()->
                        
                        ret = false

                        for col, idx in grid.headerCt.gridDataColumns 
                          unless col.xtype in ['gridcolumn', 'rownumberer']
                            ori_idx = col.initialConfig.ori_idx  
                            unless ori_idx == idx
                              ret = true 
                              return true 

                        ret

                      reorder_fn =()->
                        idx = -1
                        r = Ext.Array.filter grid.headerCt.gridDataColumns, (e)->
                          idx += 1
                          unless e.initialConfig.ori_idx == idx
                            e.initialConfig.current_idx = idx
                            return true 
                          false

                        col = r[0]
                        unless Ext.isEmpty col
                          ori_idx     = col.initialConfig.ori_idx
                          unless Ext.isEmpty ori_idx
                            current_idx = col.initialConfig.current_idx
                            grid.headerCt.move current_idx, ori_idx 
                            win.updateProgress 0.3, "Move Column From #{current_idx} to #{ori_idx}"
                            grid.getView().refresh(); 

                        if is_new_order()
                          Ext.Function.defer reorder_fn, 0.125
                        else
                          win.close()
                          cmp.setDisabled false
                          grid.resumeEvents()

                      reorder_fn()
                    return
                ,
                  ()->
                    cmp.setDisabled false
                    win.close()

      #gridConfig.enableColumnHide = true
      #gridConfig.enableColumnMove = true
       
      for col in Ext.valueFrom columnConfig.columns, []
        if col.xtype == 'rownumberer'
          Ext.apply col,
            hideable: false
            sortable: false
       
    grid_list = Ext.create 'Ext.grid.Panel', gridConfig

    grid_list.enquiry = Ext.valueFrom columnConfig.enquiry, false
    grid_list.init_filter = Ext.valueFrom columnConfig.init_filter, false

    store.grid_list = grid_list

    grid_list