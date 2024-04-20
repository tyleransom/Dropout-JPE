function P=searchconsumpplogit(b,offer,st,grad_4yr,sdemog,S)

    P = zeros(size(offer,1),20);
    alpha    = b(1);
    galpha   = b(2);
    b2flg    = 2+[1:st.number2];
    b4sflg   = 2+[1+st.number2:st.number2+st.number4s];
    b4nsflg  = 2+[1+st.number2+st.number4s:st.number2+st.number4s+st.number4ns];
    bwptflg  = 2+[1+st.number2+st.number4s+st.number4ns:st.number2+st.number4s+st.number4ns+st.numberpt];
    bgwptflg = 2+[1+st.number2+st.number4s+st.number4ns+st.numberpt:st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt]; 
    bwftflg  = 2+[1+st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt:st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft];
    bgwftflg = 2+[1+st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft:st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft+st.numbergft];
    bwcflg   = 2+[1+st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft+st.numbergft:st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft+st.numbergft+st.numberwc];
    bgwcflg  = 2+[1+st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft+st.numbergft+st.numberwc:st.number2+st.number4s+st.number4ns+st.numberpt+st.numbergpt+st.numberft+st.numbergft+st.numberwc+st.numbergwc];

    b2        = b(b2flg);
    b2temp    = [b2(1:sdemog+3);0;b2(sdemog+4:end-7);0;b2(end-6:end)];% first 0: consumption; second 0: white_collar
    b4s       = b(b4sflg);
    b4stemp   = [b4s(1:sdemog+3);0;b4s(sdemog+4:end-7);0;b4s(end-6:end)];
    b4ns      = b(b4nsflg);
    b4nstemp  = [b4ns(1:sdemog+3);0;b4ns(sdemog+4:end-7);0;b4ns(end-6:end)];
    bwpt      = b(bwptflg);
    bwpttemp  = [bwpt(1:sdemog);0;bwpt(sdemog+1:sdemog+2);0;bwpt(sdemog+3:end-3);0;0;0;0;bwpt(end-2:end)];% first two 0s: academic ability, consumption; second four 0s: workPT, workFT, workPT*white_collar, workFT*white_collar
    bwft      = b(bwftflg);
    bwfttemp  = [bwft(1:sdemog);0;bwft(sdemog+1:sdemog+2);0;bwft(sdemog+3:end-3);0;0;0;0;0;bwft(end-2:end)];% first two 0s: academic ability, consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC
    bwc       = b(bwcflg);
    bwctemp   = [bwc(1:sdemog);0;0;0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];% first four 0s: academic ability, accum. debt (and squared), consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC 

    bgwpt     = b(bgwptflg);
    bgwpttemp = bgwpt(1:10);
    bgwpttflg = find(bgwpttemp~=0);
    bgwft     = b(bgwftflg);
    bgwfttemp = bgwft(1:10);
    bgwfttflg = find(bgwfttemp~=0);
    bgwc      = b(bgwcflg);
    bgwctemp  = bgwc(1:10);
    bgwctflg  = find(bgwctemp~=0);

    % indices to flag consumption and non-consumption covariates in matrices
    cidx  = sdemog+4;
    gcidx = 11;

    % "utility" for 2-year college:
    vng2ftbc = (st.X2ftbc*(b2temp+bwfttemp        )+st.X2ftbc(:,cidx)*alpha);
    vng2ftwc = (st.X2ftwc*(b2temp+bwfttemp+bwctemp)+st.X2ftwc(:,cidx)*alpha);
    vng2ptbc = (st.X2ptbc*(b2temp+bwpttemp        )+st.X2ptbc(:,cidx)*alpha);
    vng2ptwc = (st.X2ptwc*(b2temp+bwpttemp+bwctemp)+st.X2ptwc(:,cidx)*alpha);
    vng2     = (st.X2nw*(  b2temp                 )+st.X2nw(  :,cidx)*alpha);

    % "utility" for 4-year college: Science majors
    vng4sftbc = (st.X4sftbc*(b4stemp+bwfttemp        )+st.X4sftbc(:,cidx)*alpha);
    vng4sftwc = (st.X4sftwc*(b4stemp+bwfttemp+bwctemp)+st.X4sftwc(:,cidx)*alpha);
    vng4sptbc = (st.X4sptbc*(b4stemp+bwpttemp        )+st.X4sptbc(:,cidx)*alpha);
    vng4sptwc = (st.X4sptwc*(b4stemp+bwpttemp+bwctemp)+st.X4sptwc(:,cidx)*alpha);
    vng4s     = (st.X4snw*(  b4stemp                 )+st.X4snw(  :,cidx)*alpha);

    % Non-Science majors
    vng4nsftbc = (st.X4nsftbc*(b4nstemp+bwfttemp        )+st.X4nsftbc(:,cidx)*alpha);
    vng4nsftwc = (st.X4nsftwc*(b4nstemp+bwfttemp+bwctemp)+st.X4nsftwc(:,cidx)*alpha);
    vng4nsptbc = (st.X4nsptbc*(b4nstemp+bwpttemp        )+st.X4nsptbc(:,cidx)*alpha);
    vng4nsptwc = (st.X4nsptwc*(b4nstemp+bwpttemp+bwctemp)+st.X4nsptwc(:,cidx)*alpha);
    vng4ns     = (st.X4nsnw*(  b4nstemp                 )+st.X4nsnw(  :,cidx)*alpha);

    % "utility" for working
    vngwptbc = (st.Xngwptbc*(bwpttemp        )+st.Xngwptbc(:,cidx)*alpha);
    vngwptwc = (st.Xngwptwc*(bwpttemp+bwctemp)+st.Xngwptwc(:,cidx)*alpha);
    vngwftbc = (st.Xngwftbc*(bwfttemp        )+st.Xngwftbc(:,cidx)*alpha);
    vngwftwc = (st.Xngwftwc*(bwfttemp+bwctemp)+st.Xngwftwc(:,cidx)*alpha);

    % "utility" for grad school 
    vgwptbc = (st.Xngwptbc*( bwpttemp        )+st.Xgwptbc(:,bgwpttflg)*(bgwpttemp         )+st.Xgwptbc( :,gcidx)*galpha);
    vgwptwc = (st.Xngwptwc*( bwpttemp+bwctemp)+st.Xgwptwc(:,bgwpttflg)*(bgwpttemp+bgwctemp)+st.Xgwptwc( :,gcidx)*galpha);
    vgwftbc = (st.Xngwftbc*( bwfttemp        )+st.Xgwftbc(:,bgwfttflg)*(bgwfttemp         )+st.Xgwftbc( :,gcidx)*galpha);
    vgwftwc = (st.Xngwftwc*( bwfttemp+bwctemp)+st.Xgwftwc(:,bgwfttflg)*(bgwfttemp+bgwctemp)+st.Xgwftwc( :,gcidx)*galpha);

    %% Compute logit probabilities
    % Part 1a: non-grad but no white collar offer
    log_dem_ngno = log(1+exp(vng2ftbc)+exp(vng2ptbc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sptbc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsptbc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwftbc));
    log_p2ftbc_ngno   = vng2ftbc  -log_dem_ngno; %alt 1
    log_p2ptbc_ngno   = vng2ptbc  -log_dem_ngno; %alt 3
    log_p2_ngno       = vng2      -log_dem_ngno; %alt 5
    log_p4sftbc_ngno  = vng4sftbc -log_dem_ngno; %alt 6
    log_p4sptbc_ngno  = vng4sptbc -log_dem_ngno; %alt 8
    log_p4s_ngno      = vng4s     -log_dem_ngno; %alt 10
    log_p4nsftbc_ngno = vng4nsftbc-log_dem_ngno; %alt 11
    log_p4nsptbc_ngno = vng4nsptbc-log_dem_ngno; %alt 13
    log_p4ns_ngno     = vng4ns    -log_dem_ngno; %alt 15
    log_pwptbc_ngno   = vngwptbc  -log_dem_ngno; %alt 16
    log_pwftbc_ngno   = vngwftbc  -log_dem_ngno; %alt 18
    log_ph_ngno       =           -log_dem_ngno; %alt 20
    P(grad_4yr==0 & offer==0,[1 3 5 6 8 10 11 13 15 16 18 20]) = cat(2,exp(log_p2ftbc_ngno  (grad_4yr==0 & offer==0)),... %alt 1
                                                                       exp(log_p2ptbc_ngno  (grad_4yr==0 & offer==0)),... %alt 3
                                                                       exp(log_p2_ngno      (grad_4yr==0 & offer==0)),... %alt 5
                                                                       exp(log_p4sftbc_ngno (grad_4yr==0 & offer==0)),... %alt 6
                                                                       exp(log_p4sptbc_ngno (grad_4yr==0 & offer==0)),... %alt 8
                                                                       exp(log_p4s_ngno     (grad_4yr==0 & offer==0)),... %alt 10
                                                                       exp(log_p4nsftbc_ngno(grad_4yr==0 & offer==0)),... %alt 11
                                                                       exp(log_p4nsptbc_ngno(grad_4yr==0 & offer==0)),... %alt 13
                                                                       exp(log_p4ns_ngno    (grad_4yr==0 & offer==0)),... %alt 15
                                                                       exp(log_pwptbc_ngno  (grad_4yr==0 & offer==0)),... %alt 16
                                                                       exp(log_pwftbc_ngno  (grad_4yr==0 & offer==0)),... %alt 18
                                                                       exp(log_ph_ngno      (grad_4yr==0 & offer==0)));   %alt 20

    % Part 1b: non-grad but received white collar offer
    log_dem_ngof = log(1+exp(vng2ftbc)+exp(vng2ftwc)+exp(vng2ptbc)+exp(vng2ptwc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sftwc)+exp(vng4sptbc)+exp(vng4sptwc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsftwc)+exp(vng4nsptbc)+exp(vng4nsptwc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwptwc)+exp(vngwftbc)+exp(vngwftwc));
    log_p2ftbc_ngof   = vng2ftbc  -log_dem_ngof; %alt  1
    log_p2ftwc_ngof   = vng2ftwc  -log_dem_ngof; %alt  2
    log_p2ptbc_ngof   = vng2ptbc  -log_dem_ngof; %alt  3
    log_p2ptwc_ngof   = vng2ptwc  -log_dem_ngof; %alt  4
    log_p2_ngof       = vng2      -log_dem_ngof; %alt  5
    log_p4sftbc_ngof  = vng4sftbc -log_dem_ngof; %alt  6
    log_p4sftwc_ngof  = vng4sftwc -log_dem_ngof; %alt  7
    log_p4sptbc_ngof  = vng4sptbc -log_dem_ngof; %alt  8
    log_p4sptwc_ngof  = vng4sptwc -log_dem_ngof; %alt  9
    log_p4s_ngof      = vng4s     -log_dem_ngof; %alt 10
    log_p4nsftbc_ngof = vng4nsftbc-log_dem_ngof; %alt 11
    log_p4nsftwc_ngof = vng4nsftwc-log_dem_ngof; %alt 12
    log_p4nsptbc_ngof = vng4nsptbc-log_dem_ngof; %alt 13
    log_p4nsptwc_ngof = vng4nsptwc-log_dem_ngof; %alt 14
    log_p4ns_ngof     = vng4ns    -log_dem_ngof; %alt 15
    log_pwptbc_ngof   = vngwptbc  -log_dem_ngof; %alt 16
    log_pwptwc_ngof   = vngwptwc  -log_dem_ngof; %alt 17
    log_pwftbc_ngof   = vngwftbc  -log_dem_ngof; %alt 18
    log_pwftwc_ngof   = vngwftwc  -log_dem_ngof; %alt 19
    log_ph_ngof       =           -log_dem_ngof; %alt 20
    P(grad_4yr==0 & offer==1,1:20) = cat(2,exp(log_p2ftbc_ngof  (grad_4yr==0 & offer==1)),... %alt  1
                                           exp(log_p2ftwc_ngof  (grad_4yr==0 & offer==1)),... %alt  2
                                           exp(log_p2ptbc_ngof  (grad_4yr==0 & offer==1)),... %alt  3
                                           exp(log_p2ptwc_ngof  (grad_4yr==0 & offer==1)),... %alt  4
                                           exp(log_p2_ngof      (grad_4yr==0 & offer==1)),... %alt  5
                                           exp(log_p4sftbc_ngof (grad_4yr==0 & offer==1)),... %alt  6
                                           exp(log_p4sftwc_ngof (grad_4yr==0 & offer==1)),... %alt  7
                                           exp(log_p4sptbc_ngof (grad_4yr==0 & offer==1)),... %alt  8
                                           exp(log_p4sptwc_ngof (grad_4yr==0 & offer==1)),... %alt  9
                                           exp(log_p4s_ngof     (grad_4yr==0 & offer==1)),... %alt 10
                                           exp(log_p4nsftbc_ngof(grad_4yr==0 & offer==1)),... %alt 11
                                           exp(log_p4nsftwc_ngof(grad_4yr==0 & offer==1)),... %alt 12
                                           exp(log_p4nsptbc_ngof(grad_4yr==0 & offer==1)),... %alt 13
                                           exp(log_p4nsptwc_ngof(grad_4yr==0 & offer==1)),... %alt 14
                                           exp(log_p4ns_ngof    (grad_4yr==0 & offer==1)),... %alt 15
                                           exp(log_pwptbc_ngof  (grad_4yr==0 & offer==1)),... %alt 16
                                           exp(log_pwptwc_ngof  (grad_4yr==0 & offer==1)),... %alt 17
                                           exp(log_pwftbc_ngof  (grad_4yr==0 & offer==1)),... %alt 18
                                           exp(log_pwftwc_ngof  (grad_4yr==0 & offer==1)),... %alt 19
                                           exp(log_ph_ngof      (grad_4yr==0 & offer==1)));   %alt 20

    % Part 2a: graduated but no white collar offer
    log_dem_grno     = log(1+exp(vgwptbc)+exp(vgwftbc));
    log_pwptbc_grno  = vgwptbc-log_dem_grno; %alt 16
    log_pwftbc_grno  = vgwftbc-log_dem_grno; %alt 18
    log_ph_grno      =        -log_dem_grno; %alt 20
    P(grad_4yr==1 & offer==0,[16 18 20]) = cat(2,exp(log_pwptbc_grno (grad_4yr==1 & offer==0)),... %alt 16
                                                 exp(log_pwftbc_grno (grad_4yr==1 & offer==0)),... %alt 18
                                                 exp(log_ph_grno     (grad_4yr==1 & offer==0)));   %alt 20




    % Part 2b: graduated and received white collar offer
    log_dem_grof     = log(1+exp(vgwptbc)+exp(vgwptwc)+exp(vgwftbc)+exp(vgwftwc));
    log_pwptbc_grof  = vgwptbc-log_dem_grof; %alt 16).*log_pwptbc_grof  +...
    log_pwptwc_grof  = vgwptwc-log_dem_grof; %alt 17).*log_pwptwc_grof  +...
    log_pwftbc_grof  = vgwftbc-log_dem_grof; %alt 18).*log_pwftbc_grof  +...
    log_pwftwc_grof  = vgwftwc-log_dem_grof; %alt 19).*log_pwftwc_grof  +...
    log_ph_grof      =        -log_dem_grof; %alt 20).*log_ph_grof      +...
    P(grad_4yr==1 & offer==1,16:20) = cat(2,exp(log_pwptbc_grof (grad_4yr==1 & offer==1)),... %alt 16
                                            exp(log_pwptwc_grof (grad_4yr==1 & offer==1)),... %alt 17
                                            exp(log_pwftbc_grof (grad_4yr==1 & offer==1)),... %alt 18
                                            exp(log_pwftwc_grof (grad_4yr==1 & offer==1)),... %alt 19
                                            exp(log_ph_grof     (grad_4yr==1 & offer==1)));   %alt 20
end 

