// ALign right
Ext.override(Ext.form.field.Number, {
    cls: 'x-number-field',
    hideTrigger: true
});

// Format Number field
// 
Ext.define('Xsk.form.FormatNumberField', {
    extend: 'Ext.form.NumberField',
    alias: ['widget.formatnumber'],
    baseChars: "0123456789",
    maxLength: 16,
    do_format: function(){
        this.setFormatValue(this.getValue());
    },
    setFormatValue: function(value){
        this.setValue(value); // set value in activetab
        if (this.format)
        {
            var numberFormat = this.format;
        }
        else
        {
            var numberFormat = ((this.isCurrency? '0,000': '0') 
                                  + (this.decimalPrecision > 0 ? '.00000000000000000000'.substring(0, this.decimalPrecision+1): ''));
        }
        this.setRawValue(Ext.util.Format.number(value, numberFormat)); // set value in inactivetab
    },
    getRawValue: function(){
        var value = this.callParent(arguments);
        return value? value.replace(/,/g, ""): value;
    },
    listeners: {
        focus: function(){
            this.setRawValue.call(this, this.getValue());
        },
        blur: function(){
            var oldValue = this.getValue();
            this.setFormatValue(oldValue);
            // fireEvent change when blur for prevent bug tab and click act different(fire event change)
            this.fireEvent('change', this, this.getRawValue(), oldValue);
        }
    }
});