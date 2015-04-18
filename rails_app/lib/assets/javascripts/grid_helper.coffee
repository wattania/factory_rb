Ext.define 'GridHelper',
  statics:
    set_column_event: (grid, rest_client, name, fn_grid_load)->
      grid.on 'columnmove', (ct, column, from_idx, to_idx)->
        grid = ct.up('grid')
        orders = []
        idx = -1
        for col in grid.getView().getGridColumns()
          idx += 1
          didx = col.dataIndex 
          unless Ext.isEmpty didx
            orders.push {didx, idx: idx}
          else
            if col.xtype in ['rownumberer']
              orders.push {'rownumberer', idx: idx}
        ###
        rest_client.create 'column_event', {}, 
          (response)->
        ,
          ()->
        ,
          jsonData:
            column: column.dataIndex
            program: name
            event: 'columnmove'
            from_idx: from_idx
            to_idx: to_idx
            orders: orders
        ###
        return

      grid.on 'columnshow', (ct, column)->
        ###
        rest_client.create 'column_event', {}, 
          (response)->
        ,
          ()->
        ,
          jsonData:
            column: column.dataIndex
            program: name
            event: 'columnshow'
        ###
        return

      grid.on 'columnhide', (ct, column)->
        column.initialConfig.mark_hidden = true
        ###
        rest_client.create 'column_event', {}, 
          (response)->
        ,
          ()->
        ,
          jsonData:
            column: column.dataIndex
            program: name
            event: 'columnhide'
        ###
        return

      grid.on 'columnresize', (ct, column, width)->
        ###
        rest_client.create 'column_event', {},
          (response)->
        ,
          ()->
        ,
          jsonData:
            column: column.dataIndex
            width: width
            program: name
            event: 'columnresize'
        ###
        return

      grid.on 'sortchange', (ct, column, direction)->
        grid = ct.up('grid')   
        if Ext.isEmpty direction
          grid.getStore().sorters.clear()# = new Ext.util.MixedCollection()
          fn_grid_load grid if Ext.isFunction fn_grid_load
          #me.load_grid_list grid

        #grid.suspendEvents()
        #ct.clearOtherSortStates column
        #grid.resumeEvents()
        ###
        rest_client.create 'column_event', {}, 
          (response)->
        ,
          ()->
        ,
          jsonData:
            column: column.dataIndex
            direction: direction
            program: name
            event: 'sortchange'
        ###
        return

    init_column_config: (rest_client, list_config, store, name)->

      return if Ext.isEmpty rest_client
      for e in Ext.valueFrom(list_config.columns, [])
        e.ori_width = e.width

      rest_client.index 'column_config', {program: name},
        (response)->
          if response.success
            column_orders = []

            configs = Ext.valueFrom response.columns, []
            sorters = Ext.Array.filter configs, (e)->
              return true unless Ext.isEmpty e.direction
              false

            if sorters.length > 0
              store.sorters = sorters 
              store.__sorters = Ext.clone sorters

            idx = -1
            for c in list_config.columns
              idx += 1
              c.ori_idx = idx
              column_orders.push c
              if Ext.isEmpty c.dataIndex
                if c.xtype in ['rownumberer']
                  c.dataIndex = 'rownumberer'

            for config in configs

              result = Ext.Array.filter Ext.valueFrom(list_config.columns, []), (e)->
                return true if e.dataIndex == config.property
                false

              for e in result
                unless Ext.isEmpty config.idx
                  Ext.Array.remove column_orders, e
                  Ext.Array.insert column_orders, config.idx, [e]

                unless Ext.isEmpty config.width
                  e.width = config.width 

                if Ext.valueFrom config.hide, false
                  e.hidden = true
                  e.mark_hidden = true
                else
                  e.hidden = false
                  e.mark_hidden = false 
 
            unless Ext.isEmpty column_orders
              list_config.columns = column_orders
      ,
        ()->
      ,
        async: false 
      return

    col_bool_renderer: (val, meta, record, row_index, col_index, store, view)->
      return '' if Ext.isEmpty val
      switch val
        when true, 'true', 't', 'y', 'Y','yes', 'Yes'
          #return '<i class="fa fa-check-square-o fa-lg"></i>'
          true_val = @columns[col_index].initialConfig.render_true_value
          if (!Ext.isEmpty true_val) or (Ext.isString true_val)
            return true_val
          else
            #return '<i class="el-icon-ok" style="font-size: 15px;"></i>'
            return '<i class="fa fa-check" style="font-size: 15px;"></i>'
          #return '<i class="glyphicon glyphicon-check" style="font-size: 15px;"></i>'
        when false, 'false', 'f', 'n', 'N', 'no', 'No'
          false_val = @columns[col_index].initialConfig.render_false_value
          if (!Ext.isEmpty false_val) or (Ext.isString false_val)
            return false_val
          else
            return '<i class="fa fa-times" style="font-size: 15px;"></i>'
          #return '<i class="el-icon-remove" style="font-size: 15px;"></i>'
          #return '<i class="glyphicon glyphicon-unchecked" style="font-size: 15px;"></i>'
        else
          return ''

    dateColumn: (text, dataIndex)->
      text: text
      dataIndex: dataIndex 
      width: 120
      align: 'center'
      renderer: (val)-> 
        if Ext.isEmpty val
          return val
        else
          Ext.Date.format val, 'd/m/Y'

    detetime_column: (text, dataIndex)->
      text: text
      dataIndex: dataIndex
      width: 150
      align: 'center'
      renderer: (val)->
        if Ext.isEmpty val
          return val
        else
          dt = Ext.Date.parse val, "Y-m-dTH:i:sP"
          return  Ext.Date.format dt, 'd/m/Y H:i:s'

    set_zoom_column: (column, handler_fn, tooltip)->
      Ext.apply column,
        align: 'center'
        xtype: 'actioncolumn'
        width: 30
        sortable: false
        resizable: false
        draggable: false
        hideable: false
        hidden: false
        items: [
          icon: 'assets/zoom.gif'
          tooltip: Ext.valueFrom tooltip, 'View Details'
          iconCls: 'mousepointer'
          handler: handler_fn
        ]
        renderer: (value, meta)->
          meta.style = ["background-color: #e3e4e6;", "padding: 4px 6px;"].join(' ')
          value

    layout: (config)->
      ret = {}
      ret.actions = Ext.valueFrom config.actions, []
      ret.columns = []
      ret.fields  = []

      if Ext.isObject config.multi
        ret.multi = config.multi
      else
        ret.multi = true if Ext.valueFrom config.multi, false
        
      ret.enquiry = Ext.valueFrom config.enquiry, true
      ret.init_filter = Ext.valueFrom config.init_filter, false
      ret.paging = Ext.valueFrom config.paging, true

      columns = Ext.valueFrom config.columns, []

      for column in columns
        if column.type in ['zoom']
          GridHelper.set_zoom_column column, Ext.valueFrom(column.handler, Ext.emptyFn())
          ret.columns.push column
          continue
        
        field = {}
        data  = 
          hideable: true

        #if Ext.valueFrom config.enquiry, false
        #  #Ext.apply data,
        #  #  hideable: true
        #  #  sortable: true
        #else
        if ret.enquiry
          Ext.applyIf data,
            hideable: true
            sortable: true 
            possibleSortStates: ['DESC', 'ASC']

        Ext.apply data, column if Ext.isObject column

        Ext.apply data,
          text: ProgHelper.get_lang column

        data.width = column.width if column.width
        data.dataIndex = column.name
        field.name = column.name
        ret.fields.push field

        unless Ext.isEmpty column.defaultValue
          Ext.apply field,
            defaultValue: column.defaultValue

        data.renderer = column.renderer if Ext.isFunction column.renderer

        switch column.type
          when 'text'
            field.type = 'string'
          when 'number'
            Ext.apply field,
              type: 'float'  

            Ext.apply data,
              align:  'right'
              #xtype:  'numbercolumn'
              format: Ext.valueFrom column.format, '0'
              renderer: (val, meta, record, row_index, col_index, store, view)->
                grid = view.up('grid')
                 
                if Ext.isNumeric val
                  unless val == 0
                    return Ext.util.Format.number val,(Ext.valueFrom(grid.columns[col_index].format, '0'))
                  else
                    console.log grid.columns[col_index].blank_when_zero
                    if Ext.valueFrom grid.columns[col_index].blank_when_zero, true 
                      return ''
                    else
                      return Ext.util.Format.number val,(Ext.valueFrom(grid.columns[col_index].format, '0'))
                val

          when 'bool', 'boolean'
            Ext.apply field,
              type: 'string' #5180 #-เปลี่ยนเป็น bool แต่เดิมเป็น 'string'
                            # 2014-09-16 เปลี่ยนเป็น string เหมือนเดิม เพราะใช้กับ bool_render (fde261_haircut_grade)
            Ext.apply data, 
              renderer: GridHelper.col_bool_renderer

            if Ext.isEmpty data.align
              Ext.apply data,
                align: 'center'

          when 'date'
            field.type = 'date'
            
            conf = GridHelper.dateColumn data.text, data.dataIndex
            if Ext.isFunction data.renderer
              conf.renderer = data.renderer

            Ext.apply data, conf 
          when 'datetime'
            field.type = 'string'
            Ext.apply data, GridHelper.detetime_column data.text, data.dataIndex

        unless Ext.valueFrom column.hidden, false
          ret.columns.push data

      action_lists = []
      for action in ret.actions
        if Ext.isArray action
          for a in action then action_lists.push a 
        else
          action_lists.push action

      for a in action_lists

        if Ext.isString a

          ret.fields.push 
            name: "set_action_#{a}_disabled"
            type: 'boolean'
            defaultValue: false

          ret.fields.push 
            name: "set_action_#{a}_desc"
            type: 'string'
            defaultValue: ''


      ret
