Ext.define 'x_grid_action_toolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.x_grid_action_toolbar'
  dock: 'top'
  items: []
  initComponent: ()->
    @callParent arguments
    return

Ext.define 'x_grid_action',
  extend: 'Ext.grid.Panel'
  alias: 'widget.x_grid_action'
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

        if (Ext.valueFrom cmp.initialConfig.create_form, false)

          if Ext.isFunction(me.get_form_edit_layout) or Ext.isFunction(me.get_form_edit) 
            me.do_create_form me, cmp.action, grid, cmp, cmp.initialConfig.create_form, (form)->
              unless Ext.isEmpty form
                me.__show_action_form me, cmp.action, form, cmp, grid
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
      else
        button = me.__create_grid_button me, action

        toolbar_buttons.push button unless Ext.isEmpty button

    toolbar_buttons
  initComponent: ()->
    config = Ext.valueFrom @config, {}
    grid_config = GridHelper.layout grid_layout_config
    Ext.apply grid_config, { dockedItems: [] }

    toolbar_buttons = @__create_grid_actions @, grid_config

    if toolbar_buttons.length > 0
        grid_config.dockedItems.push 
          xtype: 'x_grid_action_toolbar' 
          items: toolbar_buttons


    if Ext.isFunction me.get_grid_list_layout
      grid_layout_config = me.get_grid_list_layout()
      grid_config = GridHelper.layout grid_layout_config
       
      Ext.apply grid_config, { dockedItems: [] }

      toolbar_buttons = @__create_grid_actions @, grid_config

    @callParent arguments
    return