Ext.define 'StatusMenu',
  alias: 'widget.StatusMenu'
  extend: 'Ext.panel.Panel'
  layout: { type: 'hbox'}#, align: 'stretch'}
  border: false 
  margin: '0 0 10 0'

  set_value: (data)->
    @down('displayfield[name=desc_en]').setValue "<font size=\"1\" color=#BDBDBD>#{data.desc_en}</font>"
    @down('displayfield[name=desc_th]').setValue "<font size=\"2\" >#{data.desc_th}</font>"
    if Ext.isNumber data.total 
      if data.total <= 0
        @down('button[name=total]').setVisible false

        @down('displayfield[name=desc_th]').setValue "<font size=\"2\" >#{data.desc_th}</font>"
      else
        unless Ext.valueFrom @hiddenBtn, false
          @down('button[name=total]').setVisible true

  initComponent: ->
    me = @
    @items = [
      layout: { type: 'vbox' }
      width: 35
      border: false
      padding: '5 0 0 0'
      items: [
        xtype: 'button'
        margin: '0 10 0 0'
        name: 'total'
        hidden: true#Ext.valueFrom @hiddenBtn, false
        text: text_fa_icon 'search', ''
        handler: (btn)->
          switch me.name
            when 'check_in'
              me.page.load_form me.name, {show_list_view: true}, ()-> btn.setDisabled false
            when 'problem', 'reject'
              me.page.load_page 'enquiry', {problem: (me.name == 'problem'), reject: (me.name == 'reject')}, ()-> btn.setDisabled false  
            else
              me.page.load_page me.name, {show_list_view: true}, ()-> btn.setDisabled false  
            
      ]
    ,
      layout: { type: 'vbox' }
      flex: 1
      height: 40
      border: false
      items: [
        xtype: 'displayfield'
        name: 'desc_th'
        value: ''
        height: 10
      ,
        xtype: 'displayfield'
        name: 'desc_en'
        value: ''
        height: 10
      ]
    ]
    @callParent arguments

Ext.define 'MainPage',
  extend: 'Ext.panel.Panel'
  border: false
  layout: 'card'
  load_setting_page: (program, desc, fn) -> @__load_page 'Setting', program, desc, fn
  load_page: (program, initview, fn) -> @__load_page 'Program', program, initview, fn
  load_form: (program, initview, fn) -> @__load_page 'Form', program, initview, fn
  __load_page: (group, program_name, initview, fn)->
    me = @
    me.setLoading true
    ProgHelper.get_view me, group, program_name, initview, (view)->
      me.setLoading false
      if view 
        title = "#{group}.#{program_name}"
        if Ext.isFunction view.get_title
          title = view.get_title()
      
        x = me.getLayout().setActiveItem me.add 
          xtype: 'panel'
          name: 'main_page'
          title: title
          layout: 'fit'
          tools: [
            type: 'close'
            callback: (tool)->
              me.getLayout().setActiveItem 0
              me.remove x
          ]
          items: view
        view.setLoading false
        fn true
      else
        view.setLoading false
        fn false
  remove_page: (view)->
    @getLayout().setActiveItem 0
    @remove view
  constructor: ->
    @rest_client = Ext.create 'RestClient', { url: "program_manager" }
    @callParent arguments
 
  initComponent: ->
    me = @
    @view_panel = Ext.create 'Ext.panel.Panel',
      name: 'view_panel'
      margin: '0 10 10 10'
      layout: 'border'
      border: null
      flex: 1
      items: [
        xtype: 'panel'
        region: 'center'
        border: false
      ]

    @items = [ 
      layout: { type: 'vbox', align: 'stretch' }
      listeners:
        activate1: ()->
          me.setLoading true
          me.update_status -> me.setLoading false
      border: null
      items: [ 
        height: 90
        border: null
        bodyPadding: 10
        layout: { type: 'hbox', align: 'stretch' }
        defaults:
          xtype: 'button'
          margin: '0 10 0 0'
          width: 90
          iconAlign: 'top'
          scale: 'large' 
          

        items: [
          text: "<b>Check In #{}</b>"
          program: 'check_in'
          icon: ProgHelper.img_url "shippable.png"
          handler: (btn)->
            btn.setDisabled true
            me.load_form btn.program, btn.text, ()-> btn.setDisabled false
        ,
          text: "<b>Receive From #{}</b>"
          program: 'receive' 
          icon: ProgHelper.img_url "box_add.png"
          width: 120
          handler: (btn)->
            btn.setDisabled true
            me.load_page btn.program, btn.text, ()-> btn.setDisabled false
        ,
          text: '<b>Enquiry</b>'  
          program: 'enquiry'
          icon: ProgHelper.img_url "kwikdisk.png"
          handler: (btn)->
            btn.setDisabled true
            me.load_page btn.program, btn.text, ()-> btn.setDisabled false
        ,
          xtype: 'panel'
          width: 1
        ,
          text: '<b>Customer Credit</b>' 
          program: 'customer_credit'
          icon: ProgHelper.img_url "1178579.24182cb8e41b5545d2a4d77cf79add1e.gif"
          width: 130
          handler: (btn)->
            btn.setDisabled true
            me.load_page btn.program, btn.text, ()-> btn.setDisabled false
        #,
        #  text: '<b>Customer Info</b>'  
        #  width: 130 
        #  program: 'customer_info'
        #  icon: ProgHelper.img_url "user_card.png"
        #  handler: (btn)->
        #    btn.setDisabled true
        #    me.load_page btn.program, btn.text, ()-> btn.setDisabled false
        #,
        #  text: 'TEST'
        #  width: 100
        #  program: 'test_framework'
        #  icon: ProgHelper.img_url "user_card.png"
        #  handler: (btn)->
        #    btn.setDisabled true
        #    me.load_page btn.program, {}, ()-> btn.setDisabled false   
        ,
          xtype: 'panel'
          flex: 1
          border: false
        ,
          text: '<b>Settings</b>'
          hidden: unless IS_ADMIN then true else false
          program: 'setting'
          icon: ProgHelper.img_url "advanced.png"
          margin: '0 0 0 0'
          defaults:
            handler: (btn)->
              btn.setDisabled true
              me.load_setting_page btn.program, btn.text, ()-> btn.setDisabled false
          menu: [
            text: 'User'
            program: 'user'
            handler: (btn)->
              btn.setDisabled true
              me.load_setting_page btn.program, btn.text, ()-> btn.setDisabled false
          ]
        ]
      ,
        @view_panel
      ]
    ]
    @callParent arguments