Ext.define 'x_grid_base',
  extend: 'Ext.panel.Panel'
  mixins:
    x_base: 'x_base'
    field: 'Ext.form.field.Field'
  layout: 'absolute'
  deleted: []
  get_grid_list: ()->
    @items.findBy (item)->
      item.xtype in ['gridpanel', 'grid']

  do_delete_record: (store, records)->
    me = @
    for record in Ext.valueFrom records, []
      switch record.get 'grid_action'
        when 'new'
        else
          record.set 'grid_action', 'delete'
          me.deleted.push record

      store.remove record
 

  do_delete: (grid, callback)->
    me = @
    store = grid.getStore()
    records = grid.getSelectionModel().getSelection()
    @do_delete_record store, records
    callback records if Ext.isFunction callback

  getValue: ()->
    ret = @getSubmitData()
    ret[@name]
  getSubmitData:()->  
    ret = {}
    unless @submitValue
      ret[@name] = null 
      return ret
    
    ret[@name] = 
      data:     []
      deleted:  []

    formData =  []

    grid = @get_grid_list()
    
    @fireEvent 'before_submit_data', @, grid
    
    grid.getStore().each (record)->
      formData.push record.data

    ret[@name].data = formData

    for record in @deleted
      ret[@name].deleted.push record.data

    ret
  setValue: (val)->
    grid = @get_grid_list()
    
    store = grid.getStore()

    store.removeAll()

    column_name = []
    
    for column in grid.fields
      data_index = column.name
      unless Ext.isEmpty data_index
        column_name.push data_index

    store_datas = []
    if Ext.isArray val
      for data in val
        if Ext.isObject
          tmp = {}
          for prop, value of data
            if prop in column_name
              tmp[prop] = value

        store_datas.push tmp
    else
      if Ext.isObject val
        tmp = {}
        for prop, value of data
          if prop in column_name
            tmp[prop] = value
        store_datas.push tmp

    store.add store_datas
    @deleted = []
    return