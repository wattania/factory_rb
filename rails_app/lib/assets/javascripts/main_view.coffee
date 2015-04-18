Ext.define 'MainView',
  extend: 'Ext.panel.Panel'
  layout: 'fit' 
  items: [
    border: false
    layout: {type: 'vbox', align: 'middle'}
    items: 
      xtype: 'displayfield'
      value: text_fa_icon 'refresh', "Loading...", 'fa-spin'
  ]
  constructor: ( )->
    if Ext.isFunction @get_url
      @rest_client = Ext.create 'RestClient', { url: @get_url() }
    @callParent arguments
  __get_view: (initview, fn)->
    me = @ 
    me.setLoading true
    
 
    if Ext.isFunction me.initial_view
      me.initial_view initview, (success, init)->
        if success
          me.removeAll()
          me.get_view init, (v)->  
            fn v, init
        else
          fn false
    else
      Ext.defer ()-> 
        me.removeAll()
        me.get_view initview, (v)-> 
          fn v, initview 
      , 250
