Ext.define 'RestClient',
    extend: 'Ext.Base'
    constructor: (config)-> 
        #@url = GET_PREFIX_URI config.url
        @url = config.url
        @callParent arguments

        @async = config.async
        return
    request: (aId, aRequestMethod, aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        unless Ext.isEmpty aMethod
            Ext.apply aParams,
                method: aMethod

        url = @url

        #if aRequestMethod in ['PUT', 'DELETE', 'POST']
        #    authToken aParams

        url += ( "/" + aId) if aId?

        _params = {}
        for prop, value of aParams
            _params[prop] = value unless Ext.isEmpty value

        config =
            url: url
            method: aRequestMethod
            params: _params
            success: (result)->
                response = Ext.JSON.decode result.responseText 
                unless response.success
                  if Ext.isArray response.backtrace
                    if response.backtrace.length > 0
                        if Ext.isObject aConfig
                            if Ext.valueFrom(aConfig.show_message, true)
                                Ext.create('ErrorBox',
                                    message: response.message
                                    backtrace: response.backtrace
                                ).show()
                        else
                            Ext.create('ErrorBox',
                                    message: response.message
                                    backtrace: response.backtrace
                                ).show()

                    else
                        if Ext.isObject aConfig
                            if Ext.valueFrom(aConfig.show_message, true)
                                Ext.Msg.alert 'Error', response.message
                        else
                            Ext.Msg.alert 'Error', response.message
                  else    
                    if Ext.isObject aConfig
                            if Ext.valueFrom(aConfig.show_message, true)
                                Ext.Msg.alert 'Error', response.message

                aSuccessFn response if aSuccessFn?
            failure: (result)->
                if Ext.isObject aConfig
                    if Ext.valueFrom(aConfig.show_message, true)
                        Ext.Msg.alert '', result.responseText
                else
                    Ext.Msg.alert '', result.responseText
                aFailureFn result if aFailureFn?
        if aConfig?
            Ext.apply config, aConfig

        if aRequestMethod in ['PUT', 'DELETE', 'POST']
          unless config.jsonData?
            Ext.apply config,
              jsonData: {}

          ProgHelper.auth_token config.jsonData

        Ext.Ajax.request config
        return

    index: (aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        @request null, 'GET', aMethod, aParams, aSuccessFn, aFailureFn, aConfig
        return

    create: (aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        @request null, 'POST', aMethod, aParams, aSuccessFn, aFailureFn, aConfig
        return

    show: (aId, aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        @request aId, 'GET', aMethod, aParams, aSuccessFn, aFailureFn, aConfig
        return

    update: (aId, aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        @request aId, 'PUT', aMethod, aParams, aSuccessFn, aFailureFn, aConfig
        return

    destroy: (aId, aMethod, aParams, aSuccessFn, aFailureFn, aConfig)->
        @request aId, 'DELETE', aMethod, aParams, aSuccessFn, aFailureFn, aConfig
        return