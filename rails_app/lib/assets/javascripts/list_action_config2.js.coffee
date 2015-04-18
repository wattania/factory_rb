Ext.define 'ActionConfig2',
  statics:
    btn: (config, me)->
      ret = {}
      if config.is_require_id
        ret.disabled = true
      ret

    select: (action, view)->
      me = view
      ret = 
        disabled:               true
        handle_dbl_click:       false
        require_id:             false
        active_selected:        false
        multi_selected:         false
        #cancel_text:            ProgHelper.lang ['Cancel', 'ยกเลิก']
        #cancel_fa_icon:         icon_fa_cancel()
        button_text:            ProgHelper.lang ['']
        fa_icon:                ''
        #save_button:            true
        hidden:                 false
        select:                 true
        #init_form:              false

      switch action
        when 'viewx'
          Ext.apply ret,
            button_text: button_icon_view 'View'
            iconCls: ""
            handle_dbl_click: true
            require_id: true
            save_button: false

        when 'view'
          Ext.apply ret,
            button_text:      ProgHelper.lang ['View', 'เรียกดู']
            fa_icon:  icon_fa_view()
            handle_dbl_click: true
            require_id:       true 
            active_selected: true
            create_form:      
              load_data:          true
              init_form:          false 
              save_button:         false
            
        when 'new'
          Ext.apply ret,
            disabled:         false
            button_text:      ProgHelper.lang ['New', 'สร้าง']
            fa_icon:          icon_fa_new()
            load_data:          false
            create_form:      
              load_data:          false
              init_form:          false
              close_button_text:  ProgHelper.lang ['Cancel', 'ยกเลิก']
              close_button_icon:  icon_fa_cancel()
              save_button:         true
             
        when 'edit'
          Ext.apply ret,
            button_text:      ProgHelper.lang ['Edit', 'แก้ไข']
            fa_icon:          icon_fa_edit()
            handle_dbl_click: true
            require_id:       true
            active_selected:  true
            create_form:
              load_data: true
              init_form: false
              

        when 'delete'
          Ext.apply ret,
            require_id: true
            active_selected: true
            button_text: button_icon_delete 'Delete'
            save_button: false
            do_action: (me, button, grid, callback)->
              Ext.Msg.show 
                msg: "#{button.button_text}?"
                buttons: Ext.Msg.OKCANCEL
                fn: (btn)->
                  if btn == 'ok'
                    selected = grid.getSelectionModel().getSelection()
                    if selected.length <= 0
                      Ext.Msg.alert 'No Selected!'
                      callback false
                      return

                    id = selected[0].get 'id'
                    if Ext.isEmpty id 
                      Ext.Msg.alert 'No ID!'
                      callback false 
                      return

                    lock_version = selected[0].get 'lock_version'
                    if Ext.isEmpty lock_version
                      Ext.Msg.alert 'No Lock Version!'
                      callback false 
                      return            

                    grid.setLoading button.text

                    me.rest_client.destroy id, 'delete', {lock_version: lock_version},
                      (response)->
                        console.log response

                        grid.setLoading false
                        grid.getStore().loadPage 1
                        callback response.success
                    ,
                      ()->
                        grid.setLoading false
                        callback false
                    return

      ret
      
    