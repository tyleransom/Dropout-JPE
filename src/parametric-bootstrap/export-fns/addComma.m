function numOut = addComma(numIn)
    jf=java.text.DecimalFormat; % comma for thousands, three decimal places
    numOut= char(jf.format(numIn)); % put "char(jf.format(numIn))" "char" if you don't want a number out
end
