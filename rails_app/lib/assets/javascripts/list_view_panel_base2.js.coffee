//= require grid_helper
//= require list_grid_edit
//= require list_action_config2

Ext.define 'ListViewPanelBase2',
  extend: 'Ext.panel.Panel'
  alias: "widget.ListViewPanelBase2"
  layout: 'card'
  border: false
  listeners:
    render: ()-> @setHeight @getHeight() - 1
  constructor: ()->
    @rest_client = Ext.create 'RestClient', {url: arguments[0].get_url()}
    @callParent arguments
  __do_create_form: (me, action, init, grid, cmp, callback)->
    if Ext.isFunction me.get_form_edit_layout
      layout = me.get_form_edit_layout me, action, init, grid, cmp
      form = FormHelper.layout layout
      #callback Ext.create 'Ext.form.Panel', form

    else if Ext.isFunction me.get_form_edit
      form = me.get_form_edit me, action, init, grid, cmp
      Ext.apply form, {xtype: 'form'}
      #callback form

    callback Ext.create 'Ext.form.Panel', form
    return
  __do_init_form: (me, action, init_data, load_data, grid, button, callback)->
    
    if load_data
      selection = grid.getSelectionModel().getSelection()
      if selection.length > 0 
        id = selection[0].get 'record_id' 

        lock_version = selection[0].get 'lock_version'

        if Ext.isEmpty id
          console.error 'No ID!'
          Ext.Msg.alert '', 'No ID!'
          callback false
          return
        grid.setLoading button.text
        me.rest_client.show id, "form_#{action}", {lock_version: lock_version},
          (response)->
            if response.success
              console.log "-----"
              console.log grid
              if Ext.isEmpty response.rows.lock_version
                Ext.Msg.alert '', 'ไม่มี Lock Version'
                callback false
              else if !(response.rows.lock_version.toString() == lock_version.toString())
                Ext.Msg.alert '', 'รายการมีการเปลี่ยนแปลงแล้ว </br> ไม่สามารถดำเนินการต่อได้'
                callback false
              else
                callback response.rows
            else
              callback false
            grid.setLoading false
        ,
          ()->
            callback false
            grid.setLoading false
        ,
          jsonData: 
            lock_version: lock_version
      else
        console.log "No Record Selected!"
        callback false
    else 
      grid.setLoading button.text    
      me.rest_client.create "form_#{action}", {},
        (response)->
          if response.success
            callback response.rows
          else
            callback false

          grid.setLoading false

      ,
        ()->
          callback false
          grid.setLoading false
      ,
        jsonData: 
          data: init_data
    return
  __show_action_form: (me, action, form, button, grid, init)->
    #tab = me.findParentBy (p)-> !Ext.isEmpty p.activeTab

    #tab.activeTab.ori_title = tab.activeTab.title
    #tab.activeTab.setTitle tab.activeTab.ori_title + " (" + button.text + ")"

    save_button = null

    switch Ext.valueFrom(button.initialConfig.create_form, {}).mode
      when 'window'
        default_close_text = 'Close'
      else
        default_close_text = 'Back'

    close_button = Ext.create 'Ext.button.Button',
      text: button_icon_back default_close_text
      button_text: default_close_text
      form_action: form
      #tab: tab.activeTab
      handler: (cmp)->
        selected = grid.getSelectionModel().getSelection()

        form_basic = cmp.form_action.getForm()
        if form_basic.isDirty() 
           
          console.log "--- form dirty! ---"
          form_basic.getFields().each (field)->
            #console.log field.name, " -> ", field.isDirty()
            console.log field.name, " : " if field.isDirty()
             
          Ext.Msg.show 
            msg: "Confirm to #{cmp.button_text}?"
            buttons: Ext.Msg.OKCANCEL
            fn: (button1)->
              if button1 == 'ok'

                record_id = -1
                if selected.length == 1
                  record_id = selected[0].get('record_id')
                record_id = -1 if Ext.isEmpty record_id
                
                me.__back_to_main Ext.valueFrom(button.initialConfig.create_form, {}).mode, cmp, record_id

        else
          record_id = -1
          if selected.length == 1
            record_id = selected[0].get('record_id')
          record_id = -1 if Ext.isEmpty record_id

          me.__back_to_main Ext.valueFrom(button.initialConfig.create_form, {}).mode, cmp, record_id
          #me.__back_to_main()
          #cmp.tab.setTitle cmp.tab.ori_title

    panel_config =
      layout: 'fit'
      items: [ form ]
      dockedItems: [
        xtype: 'toolbar'
        height: 30
        dock: 'top'
        items: [ 
          close_button
        ,
          '->'
        ,
          #xtype: 'button'
          xtype: 'displayfield'
          value: Ext.valueFrom button.button_text, button.text
          form_action: form
          cls: 'filter-toolbar-button'
          handler: (cmp)->
            console.log cmp.form_action.getValues()

        ]
      ]
     
    if Ext.valueFrom Ext.valueFrom(button.initialConfig.create_form, {}).save_button, true
      save_button = Ext.create 'Ext.button.Button',
        text: button_icon_save 'Save'
        button_text: 'Save'
        disabled: true
        name: 'btn_form_save'
        form_action: form
        #tab: tab.activeTab
        handler: (cmp)-> 
          return unless cmp.form_action.getForm().isValid()
          form_values = cmp.form_action.getValues()
          console.log form_values
          json_data = { data: form_values }
          return unless me.fireEvent 'before_form_save', me, action, grid, json_data, cmp.form_action

          Ext.Msg.show 
            msg: "Confirm to #{cmp.button_text}?"
            buttons: Ext.Msg.OKCANCEL
            fn: (btn)->
              if btn == 'ok' 
                ret = true
                if Ext.isFunction Ext.valueFrom(button.initialConfig.create_form, {}).before_save_form
                  ret = button.initialConfig.create_form.before_save_form me, cmp.form_action, button, grid, json_data
                else
                  ret = true

                unless ret == false
                  if Ext.valueFrom(button.initialConfig.create_form, {}).load_data
                    if Ext.isEmpty form_values.id
                      Ext.Msg.alert '', 'No ID!'
                      return
                    else
                      me.setLoading true
                      me.rest_client.update form_values.id, "#{action}", {},
                        (response)->
                          me.setLoading false
                          FormHelper.processFromResponse response, cmp.form_action, action, (res)->
                            if res
                              if Ext.isFunction Ext.valueFrom(button.initialConfig.create_form, {}).after_save_form
                                button.initialConfig.create_form.after_save_form me, response, cmp.form_action, button, grid
                              
                              me.__back_to_main Ext.valueFrom(button.initialConfig.create_form, {}).mode, cmp, response.record_id
                                
                            return
                          return
                      ,
                        ()->
                          me.setLoading false
                          return
                      ,
                        jsonData: json_data
                  else
                    me.setLoading true
                    me.rest_client.create "#{action}", {},
                      (response)->
                        me.setLoading false
                        FormHelper.processFromResponse response, cmp.form_action, action, (res)->
                          if res 
                            if Ext.isFunction Ext.valueFrom(button.initialConfig.create_form, {}).after_save_form
                              button.initialConfig.create_form.after_save_form me, response, cmp.form_action, button, grid

                            me.__back_to_main Ext.valueFrom(button.initialConfig.create_form, {}).mode, cmp, response.record_id
                          return
                        return
                    ,
                      ()->
                        me.setLoading false
                        return
                    ,
                      jsonData: json_data
              return
       
      Ext.Array.insert panel_config.dockedItems[0].items, 0, [save_button]
    
    form.getForm().on 'dirtychange', (f, b)->
      unless Ext.isEmpty close_button
        close_button.button_text = (if b then 'Cancel' else default_close_text)
        close_button.fa_icon     = (if b then 'times' else 'arrow-left')
        close_button.setText(button_fa_icon close_button.fa_icon, close_button.button_text)

      unless Ext.isEmpty save_button
        save_button.setDisabled !b
        
      return 

    unless Ext.isEmpty form.height
      Ext.apply panel_config,
        layout: 'auto'
        autoScroll: true

    me.fireEvent 'before_form_action_create', me, button.action, form, panel_config, grid, button, init

    panel = Ext.create 'Ext.panel.Panel', panel_config

    r = me.fireEvent 'before_form_action_show', me, button.action, form, panel, grid, button, init
    unless r == false
      switch Ext.valueFrom(button.initialConfig.create_form, {}).mode
        when 'window'
          
          _w = Ext.valueFrom Ext.valueFrom(button.initialConfig.create_form, {}).window_width, (outerWidth * 0.8)
          _h = Ext.valueFrom Ext.valueFrom(button.initialConfig.create_form, {}).window_height, (outerHeight * 0.75)

          Ext.create('Ext.window.Window',
            title: button.text
            modal: true
            closable: false
            cls: 'popup-panel'
            layout: 'fit'
            width: _w, 
            height: _h, 
            items: [ panel ]
          ).show()
        else
          me.add panel
          me.getLayout().setActiveItem 1
      
  __back_to_main: (mode, cmp, record_id)-> 
    me = @

    switch mode
      when 'window'
        cmp.up('window').close()
      else 
        main = me.items.getAt 0
        me.getLayout().setActiveItem 0 
        
        if Ext.isFunction(main.load_grid) and record_id != -1
          main.load_grid record_id

        form = me.items.getAt(1)
        me.remove form
    return
  do_create_form: (me, action, grid, cmp, config, callback)->

    load_data = if config.load_data then true else false
    
    layout = null
    if Ext.isObject config
      if Ext.isFunction config.init
        config.init me, grid, cmp, config, (init_data)->
          me.__do_init_form me, action, init_data, load_data, grid, cmp, (init)->
            if Ext.isObject init
              me.__do_create_form me, action, init, grid, cmp, (form)->
                callback form, init
                return
              return
            else
              callback null 
              grid.setLoading false
          return

      else if Ext.isObject config.init
        me.__do_init_form me, action, config.init, load_data, grid, cmp, (init)->
          if init
            me.__do_create_form me, action, init, grid, cmp, (form)->
              callback form, init
          else
            callback null
            grid.setLoading false

      else
        me.__do_init_form me, action, {}, load_data, grid, cmp, (init)->
          if init
            me.__do_create_form me, action, init, grid, cmp, (form)->
              callback form, init
          else
            callback null
            grid.setLoading false
       
    else
      me.__do_init_form me, action, {}, load_data, grid, cmp, (init)->
        if init
          me.__do_create_form me, action, init, grid, cmp, (form)->
            callback form, init
        else
          callback null
          grid.setLoading false   

    return
  __set_action_default_dblclick: (grid)->
    ret = null

    found = false 
    all_normal = if grid.getSelectionModel().getSelection().length == 1 then false else true
    
    grid.dockedItems.each (toolbar)->
      if (toolbar.dock == 'top')
        toolbar.items.each (item)-> 
          if Ext.isFunction item.set_bold
            if !item.isDisabled()
              if Ext.valueFrom item.handle_dbl_click, false
                unless found
                  item.set_bold true 
                  ret = item
                  found = true
                else
                  item.set_bold false
              else
                item.set_bold false

            if all_normal
              item.set_bold false
              ret = null

          return
      return
    ret
  __create_form_filter: (me, grid)->
    filter_config = null
    if Ext.isFunction me.get_form_filter_layout
      init_filter = {}
      if Ext.valueFrom me.init_filter, false
        me.rest_client.index 'init_filter', {},
          (response)->
            if response.success 
              init_filter = response.rows
        ,
          ()->
        ,
          async: false
      
      filter_config = FormHelper.layout me.get_form_filter_layout init_filter
      filter_form   = Ext.create 'Ext.form.Panel', Ext.apply filter_config,
        grid: grid
        do_filter: ()->
          if !Ext.isEmpty @grid
            if @getForm().isValid()
              store = @grid.getStore()
              store.getProxy().extraParams = @getValues()
              Ext.apply store.getProxy().extraParams,
                method: 'list'
              store.loadPage 1
          return 
      unless Ext.isEmpty grid
        grid.getStore().on 'beforeload', (store)-> 
          Ext.apply store.getProxy().extraParams, {method: 'list'}
          Ext.apply store.getProxy().extraParams, filter_form.getValues()
          true

      filter_form.on 'render', (form)-> 
        for cmp in form.query 'component[name]'
          continue if cmp.xtype in ['checkboxfield', 'checkbox']
          cmp.on 'specialkey', (field, e)->
            if (e.getKey() == e.ENTER) 
              form.do_filter()
            return
        return

      @__form_filter = filter_form
      
    if Ext.isEmpty filter_config
      null
    else
      conf =  
        height: filter_config.height + TOOLBAR_BUTTON_HEIGHT + FORM_LINE_SPACE
        do_show: (fn)->
          self = @
          self.setHeight self.ori_height
          filter_form.animate
            duration: 200
            to:
              y: self.ori_y
            listeners:
              afteranimate: ()->
                fn()
          return
        do_hide: (fn)->
          self = @
          self.ori_height = @getHeight() if Ext.isEmpty self.ori_height
          self.ori_y = filter_form.getPosition()[1] if Ext.isEmpty self.ori_y
          filter_form.animate
            duration: 300
            to:
              y: self.ori_y - filter_form.height
            listeners:
              afteranimate: ()->
                self.setHeight 0
                fn()
          return
        dockedItems: [
          xtype: 'toolbar'
          dock: 'top'
          height: 30
          items: [
            xtype: 'button'
            filter_form: filter_form 
            text: button_icon_search 'Search'
            disabled: Ext.isEmpty grid
            handler: (cmp)->
              cmp.setDisabled true
              if !Ext.isEmpty cmp.filter_form
                cmp.filter_form.do_filter()
              cmp.setDisabled false
              return
          ,
            xtype: 'button'
            filter_form: filter_form
            text: button_icon_clear 'Clear'
            handler: (cmp)->
              cmp.setDisabled true 
              unless Ext.isEmpty cmp.filter_form
                cmp.filter_form.getForm().reset()
                cmp.filter_form.do_filter()
                 
              cmp.setDisabled false
          ]
        ]
        items: [ filter_form ]
      Ext.create 'Ext.panel.Panel', conf

  __create_grid_button: (me, action)-> 
    button = null

    action_config = ActionConfig2.select action, me
    if Ext.isFunction me.get_action_config
      me.get_action_config me, action, action_config
       
    if Ext.isObject action_config
      if Ext.valueFrom action_config.require_id, false
        action_config.disabled = true

      action_config.handler =(cmp)->
        cmp.setDisabled true 
        grid = cmp.up('grid')

        _handler =(cmp)->
          if (Ext.valueFrom cmp.initialConfig.create_form, false)

            if Ext.isFunction(me.get_form_edit_layout) or Ext.isFunction(me.get_form_edit) 
              me.do_create_form me, cmp.action, grid, cmp, cmp.initialConfig.create_form, (form, init)->
                unless Ext.isEmpty form
                  me.__show_action_form me, cmp.action, form, cmp, grid, init
                cmp.setDisabled false
            else
              console.error "ERROR: NO FORM EDIT FUNCTION! (get_form_edit_layout)"
              cmp.setDisabled false
          else 
            if Ext.isFunction cmp.initialConfig.do_action 
              cmp.initialConfig.do_action me, cmp, cmp.up('grid'), (response)-> 
                me.__set_action_active grid.getSelectionModel().getSelection(), grid

            else
              console.warn "#{cmp.action}: NO ACTION DEFINED"
              me.__set_action_active grid.getSelectionModel().getSelection(), grid

          return

        if Ext.isFunction cmp.initialConfig.before_fn 
          cmp.initialConfig.before_fn (success)->
            if success
              _handler cmp 
            else
              cmp.setDisabled false
        else
          _handler cmp
        return

      Ext.apply action_config,
        text: button_fa_icon action_config.fa_icon, action_config.button_text
        set_bold: (bool)-> 
          text = (button_fa_icon @initialConfig.fa_icon, @initialConfig.button_text)
          if bool
            @setText "<b>" + text + "</b>"
          else
            @setText text
          return

      button = Ext.create 'Ext.button.Button', action_config
      button.action = action
    button
  __set_action_active: (selected, grid)-> 
    if selected.length == 1 
      select = selected[0]
      grid.dockedItems.each (toolbar)->
        if toolbar.dock == 'top'
          toolbar.items.each (item)->
            if item.xtype == 'button'
              if Ext.valueFrom item.initialConfig.active_selected, false
                item.setDisabled false
              else
                item.setDisabled false
              
              r = (select.get "set_action_#{item.action}_disabled") 
              if Ext.isBoolean r
                item.setDisabled r 

                if r
                  item.setTooltip(select.get "set_action_#{item.action}_desc") 
                else
                  item.setTooltip '' 
                
            return
        return

    else if selected.length == 0 
      grid.dockedItems.each (toolbar)->
        if toolbar.dock == 'top'
          toolbar.items.each (item)->
            if item.xtype == 'button'
              if Ext.valueFrom item.initialConfig.active_selected, false 
                item.setDisabled true
              else
                item.setDisabled false
                
            return
        return
    
    if selected.length > 1
      grid.dockedItems.each (toolbar)->
        if toolbar.dock == 'top'
          toolbar.items.each (item)->
            if item.xtype == 'button'
              if Ext.valueFrom item.initialConfig.multi_selected, false
                disabled = false
                for select in selected then disabled = true if select.get "set_action_#{item.action}_disabled"
                item.setDisabled false unless disabled
              else
                item.setDisabled true


  __select_action: (me, selected, grid)-> 
    record = selected[0]
    return if Ext.isEmpty record
    
    v = Ext.valueFrom record.get('select_action'), ''
    result = []
    top_toolbar = null
    for action in v.split('|')
      actions = action.split(',')
      continue if actions.length <= 1 
      if actions.length == 2 
        grid.dockedItems.each (toolbar)-> 
          if toolbar.dock == 'top'
            toolbar.items.each (item, index)->
              if item.xtype == 'button'
                top_toolbar = toolbar
                if (index.toString() == actions[0].toString())
                  unless item.action == actions[1]
                    if Ext.isArray item.sub_actions
                      found = false
                      for sub_action in item.sub_actions 
                        continue if found
                        if sub_action == actions[1]
                          found = true
                          new_button = me.__create_grid_button me, sub_action
                           
                          new_button.sub_actions = []
                          for a in item.sub_actions then new_button.sub_actions.push a 
                          Ext.Array.insert new_button.sub_actions, 0, [item.action] if new_button.sub_actions.indexOf(item.action) == -1
                          result[index] = new_button

              return
          return  

    unless Ext.isEmpty top_toolbar
      for res, index in result
        unless Ext.isEmpty res 
          ori = top_toolbar.items.getAt(index)
          top_toolbar.insert index, res 
          top_toolbar.remove ori, true
          
    return
  __create_grid_actions: (me, grid_config)-> 
    toolbar_buttons = [] 
    for action in (Ext.valueFrom grid_config.actions, [])
      
      first = true
      if Ext.isArray action
        ret_button = null
        for a in action 
          if first
            first = false
            btn = me.__create_grid_button me, a
            btn.sub_actions = [a]
            ret_button = btn

          else
            ret_button.sub_actions.push a

        toolbar_buttons.push ret_button unless Ext.isEmpty ret_button

      else if Ext.isObject action
        toolbar_buttons.push action

      else
        button = me.__create_grid_button me, action

        toolbar_buttons.push button unless Ext.isEmpty button

    toolbar_buttons

  initComponent: ()->
    me = @
    main_panel = 
      border: 0
      layout:
        type: 'vbox'
        align: 'stretch'
      items: []

    @items = []

    grid_config = { }

    if Ext.isFunction me.get_grid_list_layout
      grid_layout_config = me.get_grid_list_layout()
      grid_config = GridHelper.layout grid_layout_config
       
      Ext.apply grid_config, { dockedItems: [] }

      toolbar_buttons = @__create_grid_actions @, grid_config

      if toolbar_buttons.length > 0
        grid_config.dockedItems.push 
          xtype: 'toolbar'
          dock: 'top'
          height: 30
          items: toolbar_buttons

      store =  
        autoLoad: false
        fields: grid_config.fields
        data: Ext.valueFrom @value, [] 

      Ext.Array.insert store.fields, 0, [
        {name: 'select_action', type: 'string'}
      ]
 
      if Ext.valueFrom(grid_layout_config.remote_sort, true)
        Ext.apply store,
          remoteSort: true 
          
      if Ext.valueFrom(grid_layout_config.proxy_type, 'ajax') == 'ajax' 
        Ext.apply store,  
          proxy:
            type: 'ajax'
            url: me.get_url()
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

      store = Ext.create 'Ext.data.Store', store 
      values = []
      default_values = []
      store.each (record)->
        default_values.push record
        values.push record.data 
      @value = store.add values
      store.removeAll()
      store.add default_values
      
      if Ext.valueFrom grid_layout_config.paging, true
        grid_config.dockedItems.push 
          xtype: 'pagingtoolbar'
          dock: 'bottom'
          displayInfo: true
          store: store 

      Ext.apply grid_config,
        flex: 1
        store: store 
      
      if grid_layout_config.row_numberer
        if Ext.isObject grid_config.row_numberer
          Ext.Array.insert grid_config.columns, 0, [ grid_config.row_numberer ]
        else
          Ext.Array.insert grid_config.columns, 0, [ 
            xtype: 'rownumberer'
            width: 40
          ]

      if Ext.isBoolean(grid_layout_config.multi) 
        if grid_layout_config.multi
          Ext.apply grid_config,
            selModel: Ext.create 'Ext.selection.CheckboxModel', {}
     

      Ext.apply grid_config,
        listeners: 
          itemdblclick: (view, record, item, index, e, eOpts )-> 
            action = me.__set_action_default_dblclick @ 
            unless Ext.isEmpty action
              action.handler action
            return
          selectionchange: (view, selected)-> 
            grid = @
            me.__select_action me, selected, grid
            me.__set_action_active selected, grid
            me.__set_action_default_dblclick grid

            return
      
      if Ext.isFunction me.before_create_grid_list
        me.before_create_grid_list me, grid_config
      
      grid = Ext.create 'Ext.grid.Panel', grid_config
      grid.getStore().on 'load', (st, records, successful)->
        selected = grid.getSelectionModel().getSelection()
        if selected.length == 1
          select = selected[0]

          for record in (Ext.Array.filter records, (e)-> e.get('id') == select.get('id'))
            select.set 'lock_version', record.get 'lock_version'

          unless Ext.isEmpty select.get 'id' 
            grid.dockedItems.each (toolbar)->
              if toolbar.dock == 'top'
                toolbar.items.each (item)->
                  if Ext.isFunction  item.set_bold
                    if Ext.valueFrom item.initialConfig.require_id, false
                      if selected.length == 1
                        item.setDisabled false
                      else
                        sitem.setDisabled true
                    else
                      item.setDisabled false
                  return
              return
        grid.getView().refresh();
        me.__set_action_default_dblclick grid
        return
      
      if Ext.valueFrom grid_config.enquiry, true
        GridHelper.set_column_event grid, me.rest_client, me.name, (grid)->
          grid.getStore().load() if grid.getStore().remoteSort
          #me.load_grid_list grid
          return

      form_filter = me.__create_form_filter me, grid
      main_panel.grid = grid
      main_panel.load_grid =(record_id)->
        self = @ 
        @grid.getStore().load (records, operation, success)-> 
          if record_id  
            record = null
            self.grid.getStore().each (rec)->  
              record = rec if rec.get('record_id') == record_id
            
            unless Ext.isEmpty record 
              self.grid.getSelectionModel().select record

      unless Ext.isEmpty form_filter
        main_panel.items.push form_filter 
        grid.dockedItems.each (toolbar)->
          if (toolbar.dock == 'top') and (toolbar.xtype == 'toolbar')
            toolbar.add [
              '->'
            ,
              xtype: 'button'
              cls: 'filter-toolbar-button action-text'
              text: button_fa_icon 'arrow-up'
              current: 'show'
              handler: (btn)->
                btn.setDisabled true
                switch btn.current
                  when 'show' 
                    btn.setText button_fa_icon 'search', ''
                    form_filter.do_hide ()->
                      btn.setDisabled false
                      btn.current = 'hide'
                       
                  when 'hide'
                    btn.setText button_fa_icon 'arrow-up', ''
                    form_filter.do_show ()->
                      btn.setDisabled false
                      btn.current = 'show' 
            ]
            

      main_panel.items.push grid
      @grid_list = grid

      grid.getStore().loadPage 1 if Ext.valueFrom grid_layout_config.auto_load, true
    else
      form_filter = me.__create_form_filter @, null
      main_panel.items.push form_filter unless Ext.isEmpty form_filter
    
    @items = [ main_panel ]
    @callParent arguments 

    #grid.getStore().load() 