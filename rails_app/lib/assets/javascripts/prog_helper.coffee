Ext.define 'ProgHelper',
  statics:
    auth_token: (a_params)->
      if ENVERONMENT == 'test'
        a_params
      else
        Ext.apply a_params, { authenticity_token: document.getElementsByTagName("meta")[1].content }

    url: (a_url)->
      a_url
    lang: (arr)-> if Ext.isArray arr then arr[0] else null
    img_url: (img)-> ProgHelper.url "images/#{img}"
    get_lang: (obj, key = 'captions', itemIndex = null, length=null) ->
      if Ext.isObject obj
        if Ext.isArray obj.captions
          return obj.captions[0] 
        else 
          return null
      else if Ext.isArray obj
        return obj[0]
      else 
        obj
    #get_lookup: (group, program_name, desc, initview, fn)->
    get_view: (container, group, program_name, initview, fn)->
      main_view = Ext.create "#{group}.#{program_name}",
        border: null
        flex: 1 
      main_view.setLoading true
      main_view.on 'render', ()->
        main_view.setLoading true
        Ext.defer ->
          main_view.__get_view initview, (aview, init)->
            #main_view.removeAll()
            if aview  
              view = main_view.add aview 
              if Ext.isFunction main_view.bind_view_event
                main_view.bind_view_event view, init              
            main_view.setLoading false
        , 500

      fn main_view

    get_lookup: (group, program_name, initview, fn, a_opts)->
      console.log "get_lookup", arguments
      opts = a_opts
      opts = {} unless Ext.isObject a_opts

      conf =
        modal: true
        layout: 'fit'
        height: 400
        width: 700
        border: false
        lookup_result: (result)->
          fn result
          @close()
        listeners:
          show: (win)->
            win.setLoading true

            ProgHelper.get_view win, group, program_name, initview, (view)->
              win.setLoading false
              if Ext.isFunction view.get_title
                win.setTitle text_fa_icon "list-alt", view.get_title()
              win.add view
      
      if Ext.isObject opts.window_conf
        Ext.apply conf, opts.window_conf
      else if Ext.isFunction opts.window_conf
        opts.window_conf conf

      win = Ext.create 'Ext.window.Window', conf
      win.show()
