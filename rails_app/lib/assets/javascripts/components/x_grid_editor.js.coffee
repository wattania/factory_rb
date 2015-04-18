//= require components/x_grid_base

Ext.define 'x_grid_editor',
  alias: 'widget.x_grid_editor'
  extend: 'x_grid_base'
  require_columns: []
  markInvalid: (value)->
    me = @
    tabparent = @findParentBy (parent)->
      return true if (parent.name + "").indexOf('parent-tab') == 0
      false

    if value 
      dialog = @show_message_dialog value
      unless Ext.isEmpty dialog
        @add dialog 
        el = dialog.getEl()
        el.slideIn 't',
          duration: 240
          listeners:
            afteranimate: ()->
              el.setStyle 'z-index', '103'      
            beforeanimate: ()->
              me.get_grid_list().setDisabled true
              el.setStyle 'z-index', '103'
              return
    else
      @get_grid_list().setDisabled false

    FormHelper.mark_tab_parent_invalid tabparent, value
    @callParent arguments
  isValid: ()->
    me = @
    msg = []
    ret = true

    grid = @get_grid_list()
     
    store = grid.getStore() 
    store.each (record)->
      if Ext.isObject record.data
        for prop of record.data
          if Ext.Array.indexOf(me.require_columns, prop) > -1
            if Ext.isEmpty record.get prop
              ret = false
              config = Ext.Array.filter grid.columns, (e)->
                e.dataIndex == prop

              config = config[0]
              if Ext.isEmpty config
                msg.push "โปรดระบุ #{prop}"
              else
                msg.push "โปรดระบุ #{config.text}"

    if ret
      ret =  @fireEvent('validation', @, grid, msg)
      
    #@markInvalid '-' unless ret
    if msg.length > 0 
      @markInvalid msg

    ret
  create_grid_list: ()->
    me = @
    columns = [
      xtype: 'rownumberer'
      width: 45
    ]
    fields = [
      name: 'grid_action'
      type: 'string'
      defaultValue: ''
    ,
      name: 'set_action_delete_disabled'
      type: 'boolean'
      defaultValue: false
    ]

    @editableFields = []

    column_configs = Ext.valueFrom @config.columns, []

    hidden_columns = Ext.Array.filter column_configs, (e)->
      return true if e.hidden
      false

    for hh in hidden_columns
      fields.push 
        name: hh.name

    show_configs = Ext.Array.filter column_configs, (e)->
      return true unless e.hidden
      false

    for col in show_configs
      @editableFields.push col.name if Ext.valueFrom col.editable, true
      column = {}
      
      field = 
        name: col.name
        type: 'string'

      Ext.apply column,
        text: ProgHelper.get_lang col
        dataIndex: col.name

      switch col.type
        when 'number'
          Ext.apply field,
            dafaultValue: 0

          if Ext.valueFrom col.editable, true
            Ext.apply column,
              align: 'right'
              text: ProgHelper.get_lang col
              field:
                xtype: 'x_number'
                format: col.format
              renderer: (value, meta, record, rowIndex, colIndex, store, view)->
                
                meta_renderer = Ext.valueFrom(@columns[colIndex].initialConfig, {}).meta_renderer
                
                if Ext.isFunction meta_renderer
                  meta_renderer value, meta, record, rowIndex, colIndex, store, view
 
                field_name = @columns[colIndex].dataIndex
                 
                if Ext.isEmpty value
                  return value
                else
                  config = Ext.Array.filter (Ext.valueFrom store.columns, []), (e)->
                    return true if e.name == field_name

                  unless Ext.isEmpty config
                    return Ext.util.Format.number value, Ext.valueFrom config[0].format, '0'
                
                value  

        when 'text'
          if Ext.valueFrom col.editable, true
            Ext.apply column,
              text: ProgHelper.get_lang col
              field:
                xtype: 'textfield'
          else
            Ext.apply column,
              renderer: (value, meta, record, rowIndex, colIndex, store, view)->
                meta.style = 
                  "" +
                  "background-color: #BFBFBF;" +
                  "border-right: 1px solid #BFBFBF;" +
                  "padding: 4px 6px;"
                value


        when 'lookup'
          unless Ext.valueFrom @read_only, false
            text = text_fa_icon 'search', (ProgHelper.get_lang col)
          else
            text = ProgHelper.get_lang col

          Ext.apply column,
            text: text
            field:
              xtype: 'x_lookup'
              lookup_type: 'lookup_for_grid'
              lookup_name:    col.lookup_name
              display_field:  col.display_field
              value_field:    col.value_field
              select_field:   col.select_field
              init_form_filter: col.init_form_filter
              listeners:      col.listeners
              ownerGrid:      @

        when 'x_lookup_for_grid'
          unless Ext.valueFrom @read_only, false
            text = text_fa_icon 'search', (ProgHelper.get_lang col)
          else
            text = ProgHelper.get_lang col

          Ext.apply column,
            text: text
            field:
              xtype: 'x_combo_lookup'
              lookup_name:    col.lookup_name
              display_field:  col.display_field
              value_field:    col.value_field
              select_field:   col.select_field
              listeners:      col.listeners


      if Ext.valueFrom col.is_require, false
        @require_columns.push col.name unless Ext.isEmpty col.name
        unless Ext.isEmpty column.text
          unless Ext.valueFrom @read_only, false
            column.text   = column.text + " *"
            column.tdCls  = 'x-require-cell'

      Ext.apply column, col
      columns.push column

      fields.push field

    delete_button = Ext.create 'Ext.button.Button',
      xtype: 'button'
      force_disabled: false
      text: button_icon_delete 'Delete'
      action: 'delete'
      disabled: true
      handler: (cmp)->
        Ext.Msg.show 
          title:    cmp.text
          msg:      "Confirm to Delete"
          buttons:  Ext.Msg.OKCANCEL
          icon:     Ext.Msg.QUESTION
          closable: false
          fn: (btn)->
            if btn == 'ok'
              grid = cmp.up('grid')

              me.do_delete grid, ()->
                cmp.setDisabled true
                me.fireEvent 'value_change', me
                grid.checkButton()
 
            return 
 
    store = Ext.create 'Ext.data.Store',
      fields: fields
      columns: column_configs
      listeners:
        add: ()->
          me.fireEvent 'value_change', me

    grid_list_config =
      xtype: 'grid'
      width:  '100%'
      height: '100%'
      x: 0
      y: 0
      columns: columns
      fields: fields
      store: store
      viewConfig: 
        getRowClass1: (record, rowIndex, rowParams, store)-> 
          for col in me.require_columns
            if Ext.isEmpty record.get col
              return 'grid-editor-cell-error'
          return ""
           
      checkButton: ()-> 
        selected = @getSelectionModel().getSelection() 
         
        if selected.length > 0
          delete_button.setDisabled false  
          delete_button.setDisabled true if delete_button.force_disabled
        else
          delete_button.setDisabled true
        return
      listeners:
        render: ()->
          @getEl().setStyle 'z-index', '100'  
        select: ()->
          @checkButton()
        beforeedit:(e)->
          cmp = e.column.field 
          
          unless me.fireEvent 'before_edit', e
            return false
          
          me.markInvalid false

          cmp = e.column.field
          unless Ext.isEmpty cmp
            switch cmp.xtype
              when 'x_lookup'
                cmp.display_value = e.record.get "#{e.field}_desc"
                cmp.grid_data = e
                e.record.set "#{e.field}_desc", ""
                cmp.setValue = (val)-> 
                  value = {}
                  value["#{e.field}"] = val
                  @set_value_from_grid val 
            
          if e.field in me.editableFields
            delete_button.setDisabled true
          else
            @checkButton()

        edit: (editor, e)->
          me.markInvalid false

          cmp = e.column.field 
          switch cmp.xtype
            when 'x_lookup' 
              
              e.record.set "#{e.field}_desc", null
              e.record.set "#{e.field}", null

              e.record.set "#{e.field}", text_fa_icon 'spinner', '', 'fa-spin'

              cmp.do_fetch_value {field: cmp.select_field, value: cmp.getValue()}, (record)->
                old_value = e.record.get "#{e.field}"

                unless Ext.isEmpty record
                  new_value = record.get cmp.select_field

                  e.record.set "#{e.field}_desc", record.get cmp.display_field
                  e.record.set "#{e.field}", record.get cmp.select_field

                  unless old_value == new_value
                    cmp.fireEvent 'record_change', cmp, e.record, "#{e.field}", new_value, old_value

                else
                  e.record.set "#{e.field}_desc", null
                  e.record.set "#{e.field}", null 

                  unless Ext.isEmpty old_value
                    cmp.fireEvent 'record_change', cmp, e.record, "#{e.field}", new_value, old_value

                e.record.commit() 
                return

          switch e.record.get 'grid_action'
            when 'new' 
              e.record.set 'grid_action', 'new'
            else
              e.record.set 'grid_action', 'edit'
            
          e.record.commit()

          @checkButton()

          me.fireEvent 'edit', me, editor, e
          me.fireEvent 'value_change', me

    unless Ext.valueFrom @read_only, false
      grid_list_config.plugins = [
        Ext.create 'Ext.grid.plugin.CellEditing',
          clicksToEdit: 1
      ]

      @action_btns = [
        Ext.create 'Ext.button.Button',
          xtype: 'button'
          text: button_icon_new 'New'
          action: 'new'
          default_grid_action: 'new'
          handler: (cmp)->
            grid = cmp.up('grid')
            valid = me.isValid()
            if valid 
              return unless me.fireEvent 'before_action', me, 'new', grid 
              default_grid_action = Ext.valueFrom cmp.default_grid_action, 'new'
              grid.getStore().add {grid_action: default_grid_action}
      ,
        delete_button
      ]

      if Ext.isObject @config.actions
        for action, btn_config of @config.actions
          btn = Ext.create 'Ext.button.Button', btn_config
          btn.action = action
          @action_btns.push btn

      grid_list_config.dockedItems = [
        xtype: 'toolbar'
        dock: 'top'
        name: 'toolbar_action_button'
        items: @action_btns
      ]



    Ext.create 'Ext.grid.Panel', grid_list_config
  show_message_dialog: (msg)->
    height = 100
    if Ext.isArray msg
      height = (msg.length * 30) + 40

    return null unless Ext.isEmpty Ext.getCmp @id + '-message-dialog'
    me = @

    closeDialogButton = Ext.create 'Ext.button.Button',
      text: button_icon_close 'Close'
      handler: (cmp)->  
        dialog = cmp.up('panel')
        dialog.getEl().slideOut 't',
          duration: 240
          callback: ()->
            me.suspendEvents()
            me.remove dialog
            me.resumeEvents()

            me.markInvalid false
         
    grid_width = Ext.valueFrom @get_grid_list().getWidth(), 0
    if grid_width <= 0
      grid_width = outerWidth

    Ext.create 'Ext.panel.Panel', 
      id: @id + '-message-dialog'
      width:  400
      height: height
      x: (grid_width - 400) / 2
      y: 0 
      bodyStyle: 'z-index: -1'
      bodyPadding: 10
      layout: 'fit' 
      html: (Ext.valueFrom msg, []).join('</br>')
      listeners: 
        render: ()->
          return
          @getEl().slideIn 't',
            duration: 60
            callback: ()-> 
              me.get_grid_list().setDisabled true
          @getEl().setStyle 'z-index', '101'
          
      dockedItems: [
        xtype: 'toolbar'
        dock: 'top' 
        items: [
          '->'
        ,
          closeDialogButton
        ]
      ]  
  initComponent: ()->
    me = @ 

    gridList = @create_grid_list()
    gridList.on 'selectionchange', (sel, records)-> 
      if records.length == 1
        record = records[0]
        for prop,value of record.data
          if prop.startsWith 'set_action_'
            
            action = prop.split('_')[2]
            do_attr= prop.split('_')[3] 

            gridList.dockedItems.each (toolbar)->
              if toolbar.name == 'toolbar_action_button'
                toolbar.items.each (cmp)->
                  if cmp.xtype == 'button'
                    if cmp.action == action
                      switch do_attr
                        when 'disabled'
                          no_revert = me.fireEvent 'before_action_disabled', action, value, cmp, me 
                          
                          if no_revert  
                            cmp.setDisabled value
                          else
                            cmp.setDisabled !value

                          cmp.force_disabled = value
                        
                  return
              return
      return
 

    @items = [gridList]

    @callParent arguments