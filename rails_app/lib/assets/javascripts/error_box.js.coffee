Ext.define 'ErrorBox',
  alias: 'widget.ErrorBox'
  extend: 'Ext.panel.Panel'
  show: ()->
    me = @
    dialogButtons = [
      text: button_icon_close 'Close'
      handler: (cmp)->
        cmp.up('window').close()
    ]

    insert_backtrace = false

    if Ext.isArray @backtrace
      if @backtrace.length > 0
        insert_backtrace = true

        Ext.Array.insert dialogButtons, 1, [
          text: button_fa_icon 'list-alt', 'Show Details'
          handler: (cmp)->
            cmp.setDisabled true
            backtrace = me.message + "\n"
            if Ext.isArray me.backtrace
              for bb in me.backtrace
                backtrace += bb + "\n"

            textareafield = Ext.create 'Ext.form.field.TextArea',
              value: backtrace

            Ext.create('Ext.window.Window',
              cls: 'error-box'
              listeners: 
                show:()->
                  textareafield.setHeight @getHeight() - 40
                  cmp.setDisabled false

              layout: 'fit'
              border: 0
              width: outerWidth - 200
              height: outerHeight - 200
              preventHeader: true
              title: null#text_fa_icon 'fa-list-alt', 'Backtrace' 
              dockedItems: [
                xtype: 'toolbar'
                dock: 'bottom'
                items: [
                  xtype: 'button'
                  text: button_fa_icon 'envelope', 'Report Error'
                  disabled: true
                ,
                  '->'
                ,
                  text: button_fa_icon 'times', ''
                  handler: (cmp)-> cmp.up('window').close()
                ]
              ]
              items: [ textareafield ]
            ).show()
        ]

    unless insert_backtrace
      Ext.Array.insert dialogButtons, 0, [
        xtype: 'button'
        text: button_fa_icon 'arrows-alt', 'More'
        handler: (cmp)->
          Ext.create('Ext.window.Window',
            title: button_fa_icon 'th-list', 'Message'
            layout: 'border'
            height: outerHeight - 100
            width: outerWidth - 100
            cls: 'popup-panel'
            items: [
              xtype: 'panel'
              bodyPadding: 10
              dockedItems: [
                xtype: 'toolbar'
                dock: 'top'
                items: [
                  xtype: 'button'
                  text: button_icon_close 'Close'
                  handler: (cmp)->
                    cmp.up('window').close()
                ]
              ,
                xtype: 'toolbar'
                dock: 'bottom'
                items: [
                  xtype: 'button'
                  text: button_icon_close 'Close'
                  handler: (cmp)->
                    cmp.up('window').close()
                ]
              ]
              region: 'center'
              html: me.message
            ]
          ).show()
      ]


    dialog = Ext.create 'Ext.window.MessageBox', 
      buttons: dialogButtons
      resizble: true

    dialog.show
      msg: @message
      icon: Ext.valueFrom @icon, Ext.MessageBox.ERROR

    dialog.setHeight 160
    dialog.setWidth 420 

  initComponent: ()->
    @items = [

    ]
    @callParent arguments