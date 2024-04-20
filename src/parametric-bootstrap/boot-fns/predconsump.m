function consump = predconsump(j,gg,b1,b2,b3,sclr,sclr2,sclr3,consumpNaive,gr2yrpridx,gr4yrpridx,gr2yridx,gr4yridx,pt2yrpridx,pt4yrpridx,pt2yridx,pt4yridx,eloan2,eloan4);
    if ismember(j,[20])
        consump = consumpNaive;
    elseif ismember(j,1:5)
        cn = consumpNaive.*sclr(j);
        gr2yrpridx = gr2yrpridx;
        gr2yridx   = gr2yridx./10000;
        pt2yrpridx = pt2yrpridx;
        pt2yridx   = exp(pt2yridx)./10000;
        eloan2   = eloan2./10000;
        x = [ones(size(cn)) cn cn.^2 cn.*gr2yrpridx cn.*gr2yridx cn.*pt2yrpridx cn.*pt2yridx cn.*eloan2 gr2yrpridx gr2yrpridx.^2 gr2yrpridx.*gr2yridx pt2yrpridx.*gr2yrpridx pt2yridx.*gr2yrpridx eloan2.*gr2yrpridx gr2yridx gr2yridx.^2 pt2yrpridx.*gr2yridx pt2yridx.*gr2yridx eloan2.*gr2yridx pt2yrpridx pt2yrpridx.^2 pt2yridx.*pt2yrpridx eloan2.*pt2yrpridx pt2yridx pt2yridx.^2 eloan2.*pt2yridx eloan2 eloan2.^2];
        consump = x*b1(:,j);
        consump = consump./sclr(j);
    elseif ismember(j,6:15)
        cn = consumpNaive.*sclr(j);
        gr4yrpridx = gr4yrpridx;
        gr4yridx   = gr4yridx./10000;
        pt4yrpridx = pt4yrpridx;
        pt4yridx   = exp(pt4yridx)./10000;
        eloan4   = eloan4./10000;
        x = [ones(size(cn)) cn cn.^2 cn.*gr4yrpridx cn.*gr4yridx cn.*pt4yrpridx cn.*pt4yridx cn.*eloan4 gr4yrpridx gr4yrpridx.^2 gr4yrpridx.*gr4yridx pt4yrpridx.*gr4yrpridx pt4yridx.*gr4yrpridx eloan4.*gr4yrpridx gr4yridx gr4yridx.^2 pt4yrpridx.*gr4yridx pt4yridx.*gr4yridx eloan4.*gr4yridx pt4yrpridx pt4yrpridx.^2 pt4yridx.*pt4yrpridx eloan4.*pt4yrpridx pt4yridx pt4yridx.^2 eloan4.*pt4yridx eloan4 eloan4.^2];
        consump = x*b1(:,j);
        consump = consump./sclr(j);
    elseif ismember(j,16:19) && gg==0
        cn = consumpNaive.*sclr2(j-15);
        x = [ones(size(cn)) cn cn.^2]; 
        consump = x*b2(:,j-15);
        consump = consump./sclr2(j-15);
    elseif ismember(j,16:19) && gg==1
        cn = consumpNaive.*sclr3(j-15);
        x = [ones(size(cn)) cn cn.^2]; 
        consump = x*b3(:,j-15);
        consump = consump./sclr3(j-15);
    end 
end
 
