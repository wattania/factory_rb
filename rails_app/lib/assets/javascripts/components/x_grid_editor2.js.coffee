//= require components/x_grid_editor2

Ext.define 'x_grid_editor2',
  alias: 'widget.x_grid_editor2'
  extend: 'Ext.grid.Panel'
  add_records: (a_records, callback)->
    rows = []
    store = @getStore()
    records = store.add a_records
    
    store.each (row)-> rows.push row
    store.removeAll()
    
    if Ext.isArray records
      if records.length == 0
        callback()
        return 

    @setLoading true
    Ext.Function.defer (a_rows, a_selected)->
      @getStore().add a_rows
      @getSelectionModel().select a_selected
      @setLoading false

      callback() if Ext.isFunction callback
    , 
      100, @, [rows, records]
    return
  get_action_buttons: ()->
    buttons = []
    @dockedItems.each (toolbar)->
      if toolbar.name == 'actions'
        toolbar.items.each (button)-> 
          buttons.push button
          return
      return
    buttons
  listeners:
    selectionchange: (model, selected)-> 
      grid = model.view.up('x_grid_editor2')

      for button in grid.get_action_buttons()
        unless Ext.isEmpty button.active_selected
          active_selected = Ext.valueFrom button.active_selected, false
          if selected.length > 0
            if active_selected
              button.setDisabled false
            else
              button.setDisabled true
          else
            button.setDisabled true  
      
      if selected.length == 1
        record = selected[0]
        
        for prop,value of record.data
          if prop.startsWith 'set_action_'
            
            action = prop.split('_')[2]
            do_attr= prop.split('_')[3] 

            @dockedItems.each (toolbar)->
              if toolbar.name == 'actions'
                toolbar.items.each (cmp)->
                  if cmp.xtype == 'button'
                    if cmp.name == action
                      switch do_attr
                        when 'disabled'
                          cmp.setDisabled value
                          cmp.force_disabled = value
                        
                  return
              return
      return
    beforeedit:(e)->
      cmp = e.column.field 
       
      
      #me.markInvalid false

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
        
      #if e.field in me.editableFields
      #  delete_button.setDisabled true
      #else
      #  @checkButton()
      return
    edit: (editor, e)->
      #me.markInvalid false
      me = @
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
                me.fireEvent 'record_lookup_changed', me, e.record, "#{e.field}", new_value, old_value, cmp

            else
              e.record.set "#{e.field}_desc", null
              e.record.set "#{e.field}", null 

              unless Ext.isEmpty old_value
                cmp.fireEvent 'record_change', cmp, e.record, "#{e.field}", new_value, old_value
                me.fireEvent 'record_lookup_changed', me, e.record, "#{e.field}", new_value, old_value, cmp

            e.record.commit() 
            return

      e.record.commit()

      #@checkButton()

      #me.fireEvent 'edit', me, editor, e
      #me.fireEvent 'value_change', me
      return
  __create_columns: (me, config)->

    fields  = []
    
    for action in Ext.valueFrom config.actions, []
      fields.push {type: 'boolean', name: "set_action_#{action.name}_disabled", defaultValue: false}

    columns = []
    for col in Ext.valueFrom config.columns, []
       
      column = 
        text: ProgHelper.lang col.captions
        dataIndex: col.name

      field =
        name: col.name
        type: 'string'  

      switch col.type
        when 'lookup'
          unless Ext.valueFrom config.read_only, false
            text = text_fa_icon 'search', (ProgHelper.get_lang col)
          else
            text = ProgHelper.get_lang col

          Ext.apply column,
            text: text

          unless Ext.valueFrom me.read_only, false
            Ext.apply column,
              field:
                xtype: 'x_lookup'
                lookup_type: 'lookup_for_grid'
                lookup_name:    col.lookup_name
                display_field:  col.display_field
                value_field:    col.value_field
                select_field:   col.select_field
                init_form_filter: col.init_form_filter  
                listeners:      col.listeners

        when 'number'
          Ext.apply field, {dafaultValue: 0}

          if Ext.valueFrom col.editable, true
            Ext.apply column,
              align: 'right' 
              renderer: (value, meta, record, rowIndex, colIndex, store, view)->
                 
                meta_renderer = Ext.valueFrom(me.columns[colIndex].initialConfig, {}).meta_renderer
                 
                if Ext.isFunction meta_renderer
                  meta_renderer value, meta, record, rowIndex, colIndex, store, view
 
                field_name = me.columns[colIndex].dataIndex
                 
                if Ext.isEmpty value
                  return value
                else
                  config = Ext.Array.filter Ext.valueFrom(me.columns, []), (e)-> e.name == field_name

                  unless Ext.isEmpty config[0]
                    return Ext.util.Format.number value, Ext.valueFrom config[0].format, '0'
                
                value

            unless Ext.valueFrom me.read_only, false
              Ext.apply column,
                field:
                  xtype: 'x_number'
                  format: col.format


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
        else
          Ext.apply column, col

      fields.push field unless Ext.isEmpty field.name
      Ext.apply column, col
      
      columns.push column  

    me.store = Ext.create 'Ext.data.Store', 
      fields: fields
      data: Ext.valueFrom me.value, []
      proxy: 
        type: 'memory'
        reader: 
          type: 'json'
          root: 'items'
     
    me.columns = columns
    return
  __create_actions: (me, config)-> 
    button_tools = []
    for action in Ext.valueFrom config.actions, []
      button_conf = {}
      Ext.apply button_conf, action
      Ext.apply button_conf,
        text: button_fa_icon action.fa_icon, action.button_text
        handler: (cmp)->
          if Ext.isFunction cmp.do_action
            grid = cmp.up('grid')
            cmp.do_action grid, cmp, me
          return

      button_tools.push Ext.create 'Ext.button.Button', button_conf

    button_tools
  initComponent: ()-> 
    config = Ext.valueFrom @config, {}

    unless Ext.valueFrom config.read_only, false
      @plugins = [
        Ext.create 'Ext.grid.plugin.CellEditing',
          clicksToEdit: 1
      ]

    @__create_columns @, config

    if @read_only
      actions = []
    else
      actions = @__create_actions @, config
    
    if Ext.isArray actions
      if actions.length > 0
        @dockedItems = [
          xtype: 'toolbar'
          height: 30
          dock: 'top'
          name: 'actions'
          items: actions
        ]
    @callParent arguments