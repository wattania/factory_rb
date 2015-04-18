//= require icon_config
//= require prog_helper
//= require error_box
//= require components/x_base
//= require components/x_radio_group 


//= require page_manager
//= require grid_action

LOADING_MESSAGE = 'Loading...'
hideLoading = ()->
    #  Hide loading message
    Ext.get('loading').hide();
    #  Hide loading mask
    Ext.get('loading-mask').hide();
    Ext.get('loading-clear-mask').hide();

setLoadingMessage =(text)->
    document.getElementById('loading-message').innerHTML = text

showLoading = (text, isWhiteScreen)->
    console.log('show');
    setLoadingMessage(text);
    if isWhiteScreen
        Ext.get('loading-clear-mask').show();
    else
        Ext.get('loading-mask').show();

    Ext.get('loading').show();

Ext.Loader.setPath 'Program', 'assets/programs'
Ext.Loader.setPath 'Setting', 'assets/settings'
Ext.Loader.setPath 'Form', 'assets/forms'
Ext.Loader.setPath 'Lookup', 'assets/lookup'

Ext.onReady ()-> 
  @PageManager = Ext.create 'PageManager'
  hideLoading()
  return