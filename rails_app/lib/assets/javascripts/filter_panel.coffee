Ext.define 'FilterPanel',
  extend: 'Ext.panel.Panel'
  alias: 'widget.filter_panel'
  title: 'Filter'
  width: 300
  collapsed: true
  collapsible: true
  layout: 'fit' 
  get_filter_values: ()-> @filter_form.getValues()
  add_filter: (text, config)->
    me = @
    
    cmp = Ext.clone config
    
    Ext.apply cmp,
      captions: [text]
      width: me.getWidth() - 50

    cmp.xtype = 'x_text' if Ext.isEmpty config.xtype
 
    panel = Ext.create 'Ext.panel.Panel',
      cmp_name: text
      layout: type: 'hbox', align: 'stretch'
      height: 60
      border: false
      items: [
        layout: type: 'vbox'#, align: 'stretch'
        border: false
        bodyPadding: '5 0 0 2'
        items: [
          xtype: 'button'
          text: text_fa_icon 'times', ''
          cls: 'filter_remove_btn'
          panel: panel
          handler: (btn)->
            me.filter_form.remove panel
        ,
          flex: 1
          border: false 
        ]
      ,
        border: false
        layout: type: 'vbox'
        margin: '5 0 0 5'
        items: [ cmp ]
      ]

    names = []
    @filter_form.items.each (p)-> names.push p.cmp_name
    #names = names.sort()

    index = names.indexOf text
    index = 0 if index < 0

    element_total = (Ext.Array.filter names, (e)-> e == text).length
     
    @filter_form.insert (index + element_total), panel
  initComponent: ->
    me = @

    @filter_form = Ext.create 'Ext.form.Panel',
      border: false
      autoScroll: true 
      layout: type: 'vbox', align: 'stretch'

    menus = []
    if Ext.isArray @cmps
      for e in @cmps
        e.handler =(c)-> me.add_filter c.text, c.cmp
      menus = @cmps
    else
      menus = []

    me.dockedItems = [
      xtype: 'toolbar'
      dock: 'top'
      items: [
        xtype: 'button'
        text: text_fa_icon 'search', 'Search'
        handler: ()->
          me.fireEvent 'search', me, me.filter_form.getValues()
          
      ,
        '->'
      ,
        xtype: 'button'
        text: text_fa_icon 'plus', 'Add'
        menu: menus
      ,
        xtype: 'button'
        text: text_fa_icon 'eraser', 'Clear', 'fa-flip'
        handler: ()->
          me.filter_form.removeAll()
          me.fireEvent 'clear', me
      ]
    ]
    
    @items = [
      @filter_form
    ]

    @callParent arguments