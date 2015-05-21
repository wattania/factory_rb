Ext.define 'Ext.xsk.Upload5', 
  extend: 'Ext.form.Panel'
  border: false
  alias: ['widget.upload5']
  GUID : ()->
    S4 = ()->
      Math.floor(Math.random() * 0x10000).toString(16)
      
    S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()
  constructor: (config)->
    me = @
    #me._url = config.url
    Ext.apply config,
      bodyStyle: 'background-color: transparent;'
      items:[
        xtype: 'filefield'
        name: Ext.valueFrom config.name, 'file'
        width: Ext.valueFrom config.width, 100
        height: Ext.valueFrom config.height, 22
        buttonConfig: style: 'border-color: transparent;'
        style: 'margin: 0px;'
        buttonText: config.text
        buttonOnly: true
        listeners: 
          change: (cmp, value)->
            file = document.getElementById(cmp.fileInputEl.id).files[0]
            return if Ext.isEmpty file

            if Ext.isFunction config.check_name
              return if config.check_name() == false

            win = Ext.create 'Ext.window.Window',
              title: "Upload #{file.name}"
              layout: 'fit'
              modal: true
              width: 300
              height: 100
              listeners: 
                show: (win)->
                  formData = new FormData()
                  formData.append Ext.valueFrom(config.name, "file"), file
                  formData.append "authenticity_token", document.getElementsByTagName("meta")[1].content
                  formData.append "upload_id", me.GUID()
                  formData.append "method", "upload"

                  extraParams = {}
                  if Ext.isFunction config.extra_params
                    extraParams = config.extra_params()
                  else if Ext.isObject config.extra_params
                    extraParams = config.extra_params

                  if Ext.isObject extraParams
                    for prop of extraParams then formData.append prop, extraParams[prop]


                  Ext.defer ()->
                    xhr = new XMLHttpRequest()

                    xhr.upload.addEventListener "progress", (evt)->
                      percentComplete = evt.loaded / evt.total
                      console.log "upload -> percent: (", evt.loaded, evt.total, ")", percentComplete
                    , 
                      false
                        
                    xhr.addEventListener "load", (evt)->
                      console.log "Upload -> Complete" 
                    , 
                      false
                        
                    xhr.addEventListener "error", (evt)->
                      console.log "Upload -> ERROR!"
                    , 
                      false
                        
                    xhr.addEventListener "abort", (evt)->
                      console.log "Upload -> Abort"
                    , 
                      false
                    
                    xhr.addEventListener "readystatechange", (evt)->
                      if evt.target.readyState == 4
                        if evt.target.status == 200
                          try
                            response = Ext.JSON.decode evt.target.responseText
                            if response.error
                              win.setHeight 200
                              win.add 
                                xtype: 'textfield'
                                value: "<font color=red>" + response.data.message + "</font>"
                                
                              if Ext.isFunction config.callback 
                                config.callback error

                            else
                              win.close()
                              if Ext.isFunction config.callback
                                config.callback null, response.data
                                
                          catch err
                            console.log " -upload error-"
                            console.log err
                        else
                          console.log "status+++ " + evt.target.status
                    , 
                      false

                    url = Ext.valueFrom config.url, 'upload'
                    url = "#{url}/#{config.file_id}" unless Ext.isEmpty config.file_id

                    xhr.timeout = 720000
                    xhr.open (Ext.valueFrom config.method, "POST"), url, true
                    xhr.send formData
                    cmp.reset()
                  , 
                    500

            win.show()
      ]
    me.callParent [config]