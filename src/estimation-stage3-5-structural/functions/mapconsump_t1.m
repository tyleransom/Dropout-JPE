 function [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_t1(consumpstructMCint,g4,q,gr2yrpridx,gr4yrpridx,gr2yridx,gr4yridx,pt2yrpridx,pt4yrpridx,pt2yridx,pt4yridx,eloan2,eloan4);

    gr2yrpridx = gr2yrpridx(g4==0);
    gr4yrpridx = gr4yrpridx(g4==0);
    gr2yridx   = gr2yridx(g4==0)./10000;
    gr4yridx   = gr4yridx(g4==0)./10000;
    pt2yrpridx = pt2yrpridx(g4==0);
    pt4yrpridx = pt4yrpridx(g4==0);
    pt2yridx   = exp(pt2yridx(g4==0))./10000;
    pt4yridx   = exp(pt4yridx(g4==0))./10000;
    eloan2   = eloan2(g4==0)./10000;
    eloan4   = eloan4(g4==0)./10000;

    qng      = q(g4==0);
    qg       = q(g4==1);

    beta_1_5 = [];
    r2_1_5   = [];
    sclr_1_5 = [];
    for i=1:5
        disp(i);
        sclrt = 1./nanmean(consumpstructMCint.consumpNaive(g4==0,i));
        cn = consumpstructMCint.consumpNaive(g4==0,i).*sclrt;
        y = consumpstructMCint.consump_t1(g4==0,i).*sclrt;
        if i<5
            x = [ones(size(cn)) cn cn.^2 cn.*gr2yrpridx cn.*gr2yridx cn.*pt2yrpridx cn.*pt2yridx cn.*eloan2 gr2yrpridx gr2yrpridx.^2 gr2yrpridx.*gr2yridx pt2yrpridx.*gr2yrpridx pt2yridx.*gr2yrpridx eloan2.*gr2yrpridx gr2yridx gr2yridx.^2 pt2yrpridx.*gr2yridx pt2yridx.*gr2yridx eloan2.*gr2yridx pt2yrpridx pt2yrpridx.^2 pt2yridx.*pt2yrpridx eloan2.*pt2yrpridx pt2yridx pt2yridx.^2 eloan2.*pt2yridx eloan2 eloan2.^2];
            beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qng(~isnan(y)));
            yhat = x*beta_ch;
        else
            x = [ones(size(cn)) gr2yrpridx gr2yrpridx.^2 gr2yrpridx.*gr2yridx pt2yrpridx.*gr2yrpridx pt2yridx.*gr2yrpridx eloan2.*gr2yrpridx gr2yridx gr2yridx.^2 pt2yrpridx.*gr2yridx pt2yridx.*gr2yridx eloan2.*gr2yridx pt2yrpridx pt2yrpridx.^2 pt2yridx.*pt2yrpridx eloan2.*pt2yrpridx pt2yridx pt2yridx.^2 eloan2.*pt2yridx eloan2 eloan2.^2];
            beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qng(~isnan(y)));
            yhat = x*beta_ch;
            beta_ch = [beta_ch(1); zeros(7,1); beta_ch(2:end)];
        end
        beta_1_5 = [beta_1_5 beta_ch];
        SSE = norm(qng(~isnan(y)).*(y(~isnan(y))-yhat(~isnan(y))),2)^2;
        SST = norm(qng(~isnan(y)).*(y(~isnan(y))-mean(y(~isnan(y)))),2)^2;
        r2t = [size(x(~isnan(y),:),1);1-SSE/SST];
        r2_1_5 = [r2_1_5 r2t];
        sclr_1_5 = [sclr_1_5 sclrt];
    end 
    beta_6_15 = [];
    r2_6_15   = [];
    sclr_6_15 = [];
    for i=6:15
        disp(i);
        sclrt = 1./nanmean(consumpstructMCint.consumpNaive(g4==0,i));
        cn = consumpstructMCint.consumpNaive(g4==0,i).*sclrt;
        y = consumpstructMCint.consump_t1(g4==0,i).*sclrt;
        if i==10 || i==15
            x = [ones(size(cn)) gr4yrpridx gr4yrpridx.^2 gr4yrpridx.*gr4yridx pt4yrpridx.*gr4yrpridx pt4yridx.*gr4yrpridx eloan4.*gr4yrpridx gr4yridx gr4yridx.^2 pt4yrpridx.*gr4yridx pt4yridx.*gr4yridx eloan4.*gr4yridx pt4yrpridx pt4yrpridx.^2 pt4yridx.*pt4yrpridx eloan4.*pt4yrpridx pt4yridx pt4yridx.^2 eloan4.*pt4yridx eloan4 eloan4.^2];
            beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qng(~isnan(y)));
            yhat = x*beta_ch;
            beta_ch = [beta_ch(1); zeros(7,1); beta_ch(2:end)];
        else
            x = [ones(size(cn)) cn cn.^2 cn.*gr4yrpridx cn.*gr4yridx cn.*pt4yrpridx cn.*pt4yridx cn.*eloan4 gr4yrpridx gr4yrpridx.^2 gr4yrpridx.*gr4yridx pt4yrpridx.*gr4yrpridx pt4yridx.*gr4yrpridx eloan4.*gr4yrpridx gr4yridx gr4yridx.^2 pt4yrpridx.*gr4yridx pt4yridx.*gr4yridx eloan4.*gr4yridx pt4yrpridx pt4yrpridx.^2 pt4yridx.*pt4yrpridx eloan4.*pt4yrpridx pt4yridx pt4yridx.^2 eloan4.*pt4yridx eloan4 eloan4.^2];
            beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qng(~isnan(y)));
            yhat = x*beta_ch;
        end
        beta_6_15 = [beta_6_15 beta_ch];
        SSE = norm(qng(~isnan(y)).*(y(~isnan(y))-yhat(~isnan(y))),2)^2;
        SST = norm(qng(~isnan(y)).*(y(~isnan(y))-mean(y(~isnan(y)))),2)^2;
        r2t = [size(x(~isnan(y),:),1);1-SSE/SST];
        r2_6_15 = [r2_6_15 r2t];
        sclr_6_15 = [sclr_6_15 sclrt];
    end 
    beta_16_19 = [];
    r2_16_19   = [];
    sclr_16_19 = [];
    for i=16:19
        disp(i);
        sclrt = 1./nanmean(consumpstructMCint.consumpNaive(g4==0,i));
        cn = consumpstructMCint.consumpNaive(g4==0,i).*sclrt;
        y = consumpstructMCint.consump_t1(g4==0,i).*sclrt;
        x = [ones(size(cn)) cn cn.^2]; 
        beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qng(~isnan(y)));
        beta_16_19 = [beta_16_19 beta_ch];
        SSE = norm(qng(~isnan(y)).*(y(~isnan(y))-x(~isnan(y),:)*beta_ch),2)^2;
        SST = norm(qng(~isnan(y)).*(y(~isnan(y))-mean(y(~isnan(y)))),2)^2;
        r2t = [size(x(~isnan(y),:),1);1-SSE/SST];
        r2_16_19   = [r2_16_19 r2t];
        sclr_16_19 = [sclr_16_19 sclrt];
    end 
    beta_16_19 = [];
    r2_16_19   = [];
    sclr_16_19 = [];
    for i=setdiff(16:20,20)
        disp(i);
        sclrt = 1./nanmean(consumpstructMCint.consumpNaive_g(g4==1,i));
        cn = consumpstructMCint.consumpNaive_g(g4==1,i).*sclrt;
        y = consumpstructMCint.consump_g_t1(g4==1,i).*sclrt;
        x = [ones(size(cn)) cn cn.^2]; 
        beta_ch = lscov(x(~isnan(y),:),y(~isnan(y)),qg(~isnan(y)));
        beta_16_19 = [beta_16_19 beta_ch];
        SSE = norm(qng(~isnan(y)).*(y(~isnan(y))-x(~isnan(y),:)*beta_ch),2)^2;
        SST = norm(qng(~isnan(y)).*(y(~isnan(y))-mean(y(~isnan(y)))),2)^2;
        r2t = [size(x(~isnan(y),:),1);1-SSE/SST];
        r2_16_19   = [r2_16_19 r2t];
        sclr_16_19 = [sclr_16_19 sclrt];
    end 
    cmap_nograd      = [beta_1_5 beta_6_15];
    cmap_nograd_work = beta_16_19;
    cmap_grad_work   = beta_16_19;
    r2_nograd      = [r2_1_5 r2_6_15];
    r2_nograd_work = r2_16_19;
    r2_grad_work   = r2_16_19;
    scaler_nograd      = [sclr_1_5 sclr_6_15];
    scaler_nograd_work = sclr_16_19;
    scaler_grad_work   = sclr_16_19;
end
 
