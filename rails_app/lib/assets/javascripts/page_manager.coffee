//= require icon_config
//= require rest_client
//= require form_helper
//= require_directory ./components
//= require main_view
//= require main_page

Ext.define 'PageManager',
  extend: 'Ext.container.Viewport'
  layout: { type: 'vbox', align: 'stretch'}
  ori_logo: ProgHelper.img_url 'I-AM-NIKON-logo.jpeg'
  renderTo: Ext.getBody()
  listeners: 
    afterrender: (panel)->
      panel.setLoading 'Initializing'
      Ext.Ajax.request 
        url: ProgHelper.url 'initialize'
        method: 'POST'
        params: ProgHelper.auth_token {}
        success: ()-> 
          view = panel.main_panel.add Ext.create 'MainPage', { page_manager: panel }
          panel.main_panel.getLayout().setActiveItem view
          panel.setLoading false

        failure: -> 
          panel.setLoading false
  constructor: ->
    @rest_client = Ext.create 'RestClient', { url: "program_manager" }
    @callParent arguments
  set_logo: (url)->
    return if Ext.isEmpty url 

  initComponent: ->
    me = @

    @main_panel = Ext.create 'Ext.panel.Panel',
      layout: 'card'
      border: false
      flex: 1

    @items = [ 
      height: 50
      bodyPadding: 5
      border: false
      layout: {type: 'hbox', align: 'middle'}
      items: [
        xtype: 'image'
        src: @ori_logo
        height: 40
        margin: '5 0 0 5'
      ,
        flex: 1
        border: false
      , 
        xtype: 'button'
        text: "<b>#{USER_FIRST_NAME} #{USER_LAST_NAME}</b>"
        margin: '0 10 0 0'
        menu: [
          text: 'Change Profile'
        ,
          text: 'Logout'
          handler: ->
            Ext.Msg.show
              title:'Log out?'
              msg: 'Are you sure you want to logout?'
              buttons: Ext.Msg.YESNO
              icon: Ext.Msg.QUESTION
              fn: (ans)->
                if ans == 'yes'  
                  me.setLoading "Bye.."
                  Ext.Ajax.request
                    async: true
                    url: LOGOUT_URL
                    method: 'GET' 
                    success: -> document.location.href = ''
                    failure: -> document.location.href = ''
        ]
      ]
    ,
      @main_panel
    ]

    @callParent arguments

 