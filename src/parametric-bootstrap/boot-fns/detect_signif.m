function output = detect_signif(b,se)
    if abs(b/se) >= 1.96
        if sign(b)==1
            output = '+$^{\ast\ast}$';
        elseif sign(b)==-1
            output = '-$^{\ast\ast}$';
        end
    elseif abs(b/se) < 1.96 && abs(b/se) >= 1.65
        if sign(b)==1
            output = '+$^\ast$\phantom{$^{\ast}$}';
        elseif sign(b)==-1
            output = '-$^\ast$\phantom{$^{\ast}$}';
        end
    elseif b==0
        output = '';
    else
        if sign(b)==1
            output = '+\phantom{$^{\ast\ast}$}';
        elseif sign(b)==-1
            output = '-\phantom{$^{\ast\ast}$}';
        end
    end
end
