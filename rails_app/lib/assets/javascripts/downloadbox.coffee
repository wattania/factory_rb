@download_box =(url, aParams, aCallback, aMethod)->
  p = 
    authenticity_token: document.getElementsByTagName("meta")[1].content

  Ext.apply p, aParams if Ext.isObject aParams
  label = Ext.create 'Ext.form.Label',
    labelAlign: 'right'
    text: ""
    margins: '0 0 0 0'
 
  win = Ext.create 'Ext.window.Window',
    title: 'Download'
    modal: false
    width : 350
    bodyPadding: 5
    layout : 'fit'
    items : [
      xtype: 'panel'
      layout:
        type: 'fit'
      items: [
        label
      ]
    ]

  win.show()
  p.winid = win.getId()
  method = 'POST'
  method = aMethod if aMethod?
  Ext.Ajax.request
    url : url
    timeout: 300000 # 5 mins
    method: method
    params: p
    success: (result, request)->
      try
        response = Ext.JSON.decode( result.responseText);
        if response.success
          if response.hash?
            if((response.hash + "").split("-").length == 5)
              _url = Ext.urlAppend("/report?uuid=" + response.hash);
              window.open(_url, _url.replace(/\//g, '_'), 'height=' + innerHeight + ',width=' + innerWidth - 20)
            else
              if response.disposition
                _url = Ext.urlAppend("/page/download", Ext.urlEncode({hash: response.hash, name: response.name, type: response.type, disposition: response.disposition}))
                window.open(_url, _url.replace(/\//g, '_'), 'height=' + innerHeight + ',width=' + innerWidth - 20)
              else
                url = Ext.urlAppend("/page/download", Ext.urlEncode({hash: response.hash, name: response.name, type: response.type}))
                iframe = Ext.create "Ext.Component",
                  xtype : "component"
                  hidden: true
                  autoEl :
                    tag : "iframe"
                    src : url
                win.add iframe
            ##############################
            catchtime = ""
            count = 60
            c = count
            closeMe=()->
              c -= 1
              if c < 0
                win.close()
                window.clearInterval catchtime
              else
                if(c <= (count - 3))
                  win.setVisible false
            catchtime = window.setInterval closeMe, 1000
          ##############################
          else
            progress.updateText "SERVER ERROR!" + response.message
            win.close()
            Ext.Msg.alert '', response.message
        else
          progress.updateText response.message
      catch err
        Ext.Msg.alert '', result.responseText

      if aCallback?
        aCallback
          success: true
      return
    failure: (result, request)->
      progress.updateText "SERVER ERROR!"
      win.close()
      Ext.Msg.alert '', result.responseText
      if aCallback?
        aCallback
          success: false
      return
  return