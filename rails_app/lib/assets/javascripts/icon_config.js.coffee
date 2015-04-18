@text_el_icon               =(icon_name, text)->      "<i class=\"el-icon-#{icon_name}\"></i> #{text}"
@button_el_icon             =(icon_name, text)->      "<i class=\"button-el-icon el-icon-#{icon_name}\"></i> #{text}"
@text_fa_icon               =(icon_name, text, cls)-> "<i class=\"fa fa-#{icon_name} #{cls}\"></i> #{if text then text else ''}"
@text_fa_icon_suffix        =(icon_name, text, cls)-> "#{text} <i class=\"fa fa-#{icon_name} #{cls}\"></i>"
@text_glyp_icon             =(icon_name, text)->      "<i class=\"glyphicon glyphicon-#{icon_name}\"></i> #{text}"
@button_fa_icon             =(icon_name, text, cls)-> "<i class=\"button-fa-icon fa fa-#{icon_name} #{ if cls then cls else '' }\"></i> #{if ext then text else ''}"
@button_glyp_icon           =(icon_name, text)->      "<i class=\"button-glyp-icon glyphicon glyphicon-#{icon_name}\"></i> #{text}"  
@button_glyp_file_type_icon =(icon_name, text)->      "<i class=\"button-glyp-icon glyphicon filetype #{icon_name}\"></i> #{text}"   

@icon_fa_cancel =()-> 'times'
@icon_fa_ok =()-> 'check'
@icon_fa_new    =()-> 'file-o'
@icon_fa_edit   =()-> 'edit'
@icon_fa_delete =-> 'trash-o'
@icon_fa_revise =-> 'share-square-o'
@icon_fa_reject =-> 'bolt'
@icon_fa_verify =-> 'check-square-o'
@icon_fa_view   =-> 'file-text-o'

@error_box = (message="?")->
  Ext.create('ErrorBox',
    message: message
  ).show()

@text_el_icon =(icon_name, text)->
  "<i class=\"el-icon-#{icon_name}\"></i> #{text}"

@button_el_icon =(icon_name, text)->
  "<i class=\"button-el-icon el-icon-#{icon_name}\"></i> #{text}"

@text_fa_icon =(icon_name, text, cls)->
  "<i class=\"fa fa-#{icon_name} #{cls}\"></i> #{text}"

@text_fa_icon_suffix =(icon_name, text, cls)->
  "#{text} <i class=\"fa fa-#{icon_name} #{cls}\"></i>"

@button_fa_icon =(icon_name, text, cls)->
  cls = "" unless cls?
  text = "" unless text?
  "<i class=\"button-fa-icon fa fa-#{icon_name} #{cls}\"></i> #{text}"

@button_glyp_icon =(icon_name, text)->
  "<i class=\"button-glyp-icon glyphicon glyphicon-#{icon_name}\"></i> #{text}"  

@button_glyp_file_type_icon =(icon_name, text)->
  "<i class=\"button-glyp-icon glyphicon filetype #{icon_name}\"></i> #{text}"    

@button_icon_clear =(text)->
  button_fa_icon 'eraser', text, 'fa-flip-horizontal'

@button_icon_search =(text)->
  button_fa_icon 'search', 'Search'

@button_icon_view =(text="")->
  button_fa_icon 'file-text-o', text

@button_icon_new  =(text)-> button_fa_icon icon_fa_new(), text
@button_icon_edit =(text)-> button_fa_icon icon_fa_edit(), text
@button_icon_delete =(text)-> button_fa_icon icon_fa_delete(), text

@button_icon_save =(text)->
  button_fa_icon 'save', text

@button_icon_cancel =(text)-> button_fa_icon icon_fa_cancel(), text

@button_icon_yes =(text)-> button_fa_icon icon_fa_ok() , text

@button_icon_ok =(text)-> button_icon_yes text

@button_icon_close =(text)-> button_icon_cancel text

@button_icon_back =(text)->
  button_fa_icon 'arrow-left', text

@button_icon_draft =(text)->
  button_fa_icon 'floppy-o', text

@button_icon_submit =(text)->
  button_fa_icon 'share-square-o', text

@button_icon_verify =(text)-> button_fa_icon icon_fa_verify(), text 

@button_icon_revise =(text)-> button_fa_icon icon_fa_revise(), text, 'fa-flip-horizontal' 
@button_icon_reject =(text)-> button_fa_icon icon_fa_reject(), text 

@button_icon_close =(text)->
  button_fa_icon 'times', text

@button_icon_print =(text)->
  button_fa_icon 'file-text-o', text

@button_icon_preview =(text)-> button_fa_icon icon_fa_view(), text

@button_icon_export_xls =(text)-> button_icon_save text

@button_icon_reset =(text)-> button_icon_revise text
  
 