// Format Text field
// 
Ext.override(Ext.form.field.Text, {
    constructor: function(config){
        if (config && config.convertToUpperCase) {
            // The following style makes all letters uppercase when typing, 
            // but it only affects the display, actual characters are preserved
            // as typed.  That is why we need to override the getValue function. 
            config.cls = Ext.value(Ext.value(config.cls, this.cls), '') + ' text-upper';
        }
        this.callParent([config]);
    },
    getRawValue: function() {
        var me = this,
            v = me.callParent();
        if (v === me.emptyText) {
            v = '';
        }
        if (v && this.trimOutput)
        {
            v = Ext.String.trim(v);
        }
        return v;
    },
    getValue: function(){
        var value = this.callParent(arguments);
        if (value && this.convertToUpperCase && value.toUpperCase) {
            value = value.toUpperCase();
        }
        
        return value;
    }
});

Ext.define('Xsk.form.field.FormatText', {
    extend: 'Ext.form.field.Text',
    alias: ['widget.formattext'],
    maskRe: /\w/,
    constructor: function(config){
        Ext.applyIf(config, {
            formatChar: Ext.util.Format.textReplace(config.format)
        });
        
        this.callParent([config]);
        this.on('afterrender', function(){
            this.inputEl.dom.maxLength = config.format.length - config.format.replace(/x/g, '').length;
        });
    },
    setValue: function(value){
        this.callParent([this.doFormat(value)]);
        return this;
    },
    doFormat: function(value){
        if (value)
        {
            // remove all format
            value = value.replace(this.formatChar, '');
            // format
            value = Ext.util.Format.text(value, this.format);
        }
        return value;
    },
    listeners: {
        focus: function(){
            // set unformat
            this.setRawValue.call(this, this.getValue().replace(this.formatChar, ''));
        },
        blur: function(){
            var oldValue = this.getValue();
            if (oldValue != this.doFormat(oldValue))
            {
                this.setValue(oldValue);
            }
            this.fireEvent('change', this, this.getRawValue(), oldValue);
        }
    }
});

Ext.util.Format.textReplace = function(formatString){
    return new RegExp('[' + formatString.replace(/x/g, '').replace(new RegExp('\\+', 'g'), '\\+') + ']', 'g');
};

Ext.util.Format.text = function(v, formatString){
    if (!v)
    {
        return '';
    }
    for (var i=0; i<formatString.length;i++)
    {
        if (formatString[i] != 'x')
        {
            v = v.substring(0,i) + formatString[i] + v.substring(i);
        }
    }
    return v;
};