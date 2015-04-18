Ext.define 'x_image_upload',
  alias: 'widget.x_image_upload'
  extend: 'Ext.panel.Panel'
  border: false
  mixins:
    x_base: 'x_base'
    field: 'Ext.form.field.Field'
  layout: { type: 'vbox', align: 'stretch' }
  allow_file_type: []
  value: null
  listeners:
    render: (me)->
      @btn_upload.on 'change', (cmp, value)->
        file = document.getElementById(cmp.fileInputEl.id).files[0]
         
        formData = new FormData()
        formData.append "img_file", file
        formData.append "authenticity_token", document.getElementsByTagName("meta")[1].content
        formData.append "method", "upload"

        formData.append "serial_no", me.serial_no     unless Ext.isEmpty me.serial_no
        formData.append "status_name", me.status_name unless Ext.isEmpty me.status_name

        ret = me.fireEvent 'before_upload', me, formData
        return if ret == false
 
        xhr = new XMLHttpRequest()

        xhr.upload.addEventListener "progress", (evt)->
          percent_complete = evt.loaded / evt.total
          #uploadProgress.updateProgress percent_complete, "", true
          console.log "-progress-"
        , 
          false
            
        xhr.addEventListener "load", (evt)->
          #uploadProgress.updateProgress 1.0, "Upload Complete", true
          #progress.setVisible true
          a = 2
          console.log "-load-"
          me.img_panel.getLayout().setActiveItem 0
        , 
          false
            
        xhr.addEventListener "error", (evt)->
          a = 1
          me.img_panel.getLayout().setActiveItem 0
          #uploadProgress.updateProgress 0.0, "ERROR!", true
          console.log "-error-"
        , 
          false
            
        xhr.addEventListener "abort", (evt)->
          a = 2
          console.log "-abort-"
          me.img_panel.getLayout().setActiveItem 0
          #uploadProgress.updateProgress 0.0, "ABORT..", true
        , 
          false
        
        xhr.addEventListener "readystatechange", (evt)->
          console.log evt.target.readyState
          if evt.target.readyState == 4
            if evt.target.status == 200
              try
                response = Ext.JSON.decode evt.target.responseText
                if response.success
                  me.img_panel.getLayout().setActiveItem 0
                  me.img.setSrc Ext.valueFrom(response.data, {}).url
                  me.fireEvent 'dirtychange', me.isDirty()
                else 
                  Ext.Msg.alert '', response.message
              catch err
                me.img_panel.getLayout().setActiveItem 0
                console.log " -upload error-"
                console.log err 
                
            else
              me.img_panel.getLayout().setActiveItem 0
              Ext.Msg.alert '', "Server Error."

        , 
          false

        me.img_panel.getLayout().setActiveItem 1

        xhr.timeout = 720000
        xhr.open ("POST"), "img_upload", true 
        xhr.send formData
        cmp.suspendEvents()
        cmp.reset()
        cmp.resumeEvents()
        
  isDirty: ()-> 
    @img.src != @value      
  constructor: (config)->
    @config = config
    config.no_label = true
    @mixins.x_base.constructor.call @, config
    @callParent [config]
    return
  getSubmitData: ()->
    return null if Ext.isEmpty @name
    ret = {}
    ret[@name] = @getValue()
    ret
  getValue: ()->
    ret = @img.src
    ret
  setValue: (val)->
    @img.setSrc val
  initComponent: ()->
    me = @
    @btn_remove = Ext.create 'Ext.button.Button',
      width: 26
      height: 26
      disabled: if @read_only then true else false
      hidden: if @read_only then true else false
      text: text_fa_icon 'trash', ''
      margin: '3 0 3 0'
      handler: (btn)->
        return if Ext.isEmpty me.img.src
        
        Ext.Msg.show
          title:'Remove?',
          message: 'Sure?',
          buttons: Ext.Msg.OKCANCEL
          icon: Ext.Msg.QUESTION
          fn: (ans)->
            if ans == 'ok'
              me.setLoading true
              Ext.Ajax.request 
                url: 'img_upload/0'
                method: 'delete'
                params: ProgHelper.auth_token
                  method: 'image'
                  url: me.img.src
                success: (result)->
                  me.setLoading false
                  response = Ext.JSON.decode result.responseText 
                  unless response.success
                    if Ext.isArray response.backtrace
                      if response.backtrace.length > 0
                        Ext.create('ErrorBox',
                          message: response.message
                          backtrace: response.backtrace
                          ).show()
                      else
                        Ext.Msg.alert 'Error', response.message
                    else    
                      Ext.Msg.alert 'Error', response.message
                  else
                    me.img.setSrc null
                    me.fireEvent 'dirtychange', me.isDirty()

                  aSuccessFn response if aSuccessFn?
                failure: (result)->
                  me.setLoading false
                  Ext.Msg.alert '', result.responseText
 
    @btn_upload = Ext.create 'Ext.form.field.File',
      margin: '3 0 0 0'
      width: 30 
      style: 'margin: 0px;'
      disabled: if @read_only then true else false
      hidden: if @read_only then true else false
      buttonConfig: 
        style: 'height: 24px'
      buttonText: text_fa_icon 'upload', ''
      buttonOnly: true 

    @img = Ext.create 'Ext.Img', {src: @value}

    @img_panel = Ext.create 'Ext.panel.Panel',
      flex: 1
      layout: 'card'
      items: [
        @img
      ,
        html: text_fa_icon 'refresh', '', 'fa-spin'
      ]

    @items = [ 
      layout: {type: 'hbox', align: 'stretch'}
      border: false
      items: [ 
        xtype: 'displayfield'
        value: ProgHelper.get_lang @
        flex: 1
      ,
        @btn_upload
      , 
        @btn_remove 
      ]
      height: 30
    ,
      @img_panel
    ]
    @callParent arguments
    return