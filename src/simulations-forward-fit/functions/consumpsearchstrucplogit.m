function [P]=consumpsearchstrucplogit(b,offer,ut,grad_4yr,gpdiff,AdjNG,AdjG,sdemog,S,Beta)

    P = zeros(size(grad_4yr,1),20);

    b2flg   = 2+[1:ut.number2];
    b4sflg  = 2+[1+ut.number2:ut.number2+ut.number4s];
    b4nsflg = 2+[1+ut.number2+ut.number4s:ut.number2+ut.number4s+ut.number4ns];
    bwptflg = 2+[1+ut.number2+ut.number4s+ut.number4ns:ut.number2+ut.number4s+ut.number4ns+ut.numberpt];
    bwftflg = 2+[1+ut.number2+ut.number4s+ut.number4ns+ut.numberpt:ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft];
    bwcflg  = 2+[1+ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft:ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft+ut.numberwc];

    alpha     = b(1);
    rho       = b(2);
    b2        = b(b2flg);
    b2temp    = [b2(1:sdemog+1);0;b2(sdemog+2:end-7);0;0;b2(end-6:end)];% two 0s: grad_4yr, white_collar
    b4s       = b(b4sflg);
    b4stemp   = [b4s(1:sdemog+1);0;b4s(sdemog+2:end-7);0;0;b4s(end-6:end)];
    b4ns      = b(b4nsflg);
    b4nstemp  = [b4ns(1:sdemog+1);0;b4ns(sdemog+2:end-7);0;0;b4ns(end-6:end)];
    bwpt      = b(bwptflg);
    bwpttemp  = [bwpt(1:sdemog);0;0;bwpt(sdemog+1:end-3);0;0;0;0;bwpt(end-2:end)];% only two 0s here bc need to estimate white_collar parameter
    bwft      = b(bwftflg);
    bwfttemp  = [bwft(1:sdemog);0;0;bwft(sdemog+1:end-3);0;0;0;0;0;bwft(end-2:end)];
    bwc       = b(bwcflg);
    bwctemp   = [bwc(1:sdemog);0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];

    % indices to flag consumption and non-consumption covariates in matrices
    cidx      = sdemog+2;
    
    % assert gpdiff is all 0s in first five columns and last four columns
    assert(all(all(gpdiff(:,[1:5 16:19])==0)));

    % "utility" for 2-year college:
    vng2ftbc = (ut.X2ftbc*(b2temp+bwfttemp        )+ut.X2ftbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,1)*rho)+AdjNG(:,1); 
    vng2ftwc = (ut.X2ftwc*(b2temp+bwfttemp+bwctemp)+ut.X2ftwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,2)*rho)+AdjNG(:,2); 
    vng2ptbc = (ut.X2ptbc*(b2temp+bwpttemp        )+ut.X2ptbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,3)*rho)+AdjNG(:,3); 
    vng2ptwc = (ut.X2ptwc*(b2temp+bwpttemp+bwctemp)+ut.X2ptwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,4)*rho)+AdjNG(:,4); 
    vng2     = (ut.X2nw  *(b2temp                 )+ut.X2nw(  :,cidx)*alpha)+((1-Beta).*gpdiff(:,5)*rho)+AdjNG(:,5); 

    % "utility" for 4-year college: Science majors
    vng4sftbc = (ut.X4sftbc*(b4stemp+bwfttemp        )+ut.X4sftbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,6 )*rho)+AdjNG(:,6);  
    vng4sftwc = (ut.X4sftwc*(b4stemp+bwfttemp+bwctemp)+ut.X4sftwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,7 )*rho)+AdjNG(:,7);  
    vng4sptbc = (ut.X4sptbc*(b4stemp+bwpttemp        )+ut.X4sptbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,8 )*rho)+AdjNG(:,8);  
    vng4sptwc = (ut.X4sptwc*(b4stemp+bwpttemp+bwctemp)+ut.X4sptwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,9 )*rho)+AdjNG(:,9);  
    vng4s     = (ut.X4snw  *(b4stemp                 )+ut.X4snw(  :,cidx)*alpha)+((1-Beta).*gpdiff(:,10)*rho)+AdjNG(:,10); 

    % Non-Science majors
    vng4nsftbc = (ut.X4nsftbc*(b4nstemp+bwfttemp        )+ut.X4nsftbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,11)*rho)+AdjNG(:,11);  
    vng4nsftwc = (ut.X4nsftwc*(b4nstemp+bwfttemp+bwctemp)+ut.X4nsftwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,12)*rho)+AdjNG(:,12);  
    vng4nsptbc = (ut.X4nsptbc*(b4nstemp+bwpttemp        )+ut.X4nsptbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,13)*rho)+AdjNG(:,13);  
    vng4nsptwc = (ut.X4nsptwc*(b4nstemp+bwpttemp+bwctemp)+ut.X4nsptwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,14)*rho)+AdjNG(:,14);  
    vng4ns     = (ut.X4nsnw*(  b4nstemp                 )+ut.X4nsnw(  :,cidx)*alpha)+((1-Beta).*gpdiff(:,15)*rho)+AdjNG(:,15); 

    % "utility" for working
    vngwptbc = (ut.Xngwptbc*(bwpttemp        )+ut.Xngwptbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,16)*rho)+AdjNG(:,16); 
    vngwptwc = (ut.Xngwptwc*(bwpttemp+bwctemp)+ut.Xngwptwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,17)*rho)+AdjNG(:,17); 
    vngwftbc = (ut.Xngwftbc*(bwfttemp        )+ut.Xngwftbc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,18)*rho)+AdjNG(:,18); 
    vngwftwc = (ut.Xngwftwc*(bwfttemp+bwctemp)+ut.Xngwftwc(:,cidx)*alpha)+((1-Beta).*gpdiff(:,19)*rho)+AdjNG(:,19); 

    % "utility" for grad school 
    vgwptbc = (ut.Xgwptbc *(bwpttemp                )+ut.Xgwptbc( :,cidx)*alpha)+(0*rho)+AdjG(:,16); 
    vgwptwc = (ut.Xgwptwc *(bwpttemp+bwctemp        )+ut.Xgwptwc( :,cidx)*alpha)+(0*rho)+AdjG(:,17); 
    vgwftbc = (ut.Xgwftbc *(bwfttemp                )+ut.Xgwftbc( :,cidx)*alpha)+(0*rho)+AdjG(:,18); 
    vgwftwc = (ut.Xgwftwc *(bwfttemp+bwctemp        )+ut.Xgwftwc( :,cidx)*alpha)+(0*rho)+AdjG(:,19); 

    %% Form likelihood (3 parts)
    % Part 1a
    log_dem_ngno = log(1+exp(vng2ftbc)+exp(vng2ptbc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sptbc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsptbc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwftbc));
    log_p2ftbc_ngno   = vng2ftbc  -log_dem_ngno;
    log_p2ptbc_ngno   = vng2ptbc  -log_dem_ngno;
    log_p2_ngno       = vng2      -log_dem_ngno;
    log_p4sftbc_ngno  = vng4sftbc -log_dem_ngno;
    log_p4sptbc_ngno  = vng4sptbc -log_dem_ngno;
    log_p4s_ngno      = vng4s     -log_dem_ngno;
    log_p4nsftbc_ngno = vng4nsftbc-log_dem_ngno;
    log_p4nsptbc_ngno = vng4nsptbc-log_dem_ngno;
    log_p4ns_ngno     = vng4ns    -log_dem_ngno;
    log_pwptbc_ngno   = vngwptbc  -log_dem_ngno;
    log_pwftbc_ngno   = vngwftbc  -log_dem_ngno;
    log_ph_ngno       =           -log_dem_ngno;
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

    % Part 1b
    log_dem_ngof = log(1+exp(vng2ftbc)+exp(vng2ftwc)+exp(vng2ptbc)+exp(vng2ptwc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sftwc)+exp(vng4sptbc)+exp(vng4sptwc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsftwc)+exp(vng4nsptbc)+exp(vng4nsptwc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwptwc)+exp(vngwftbc)+exp(vngwftwc));
    log_p2ftbc_ngof   = vng2ftbc  -log_dem_ngof;
    log_p2ftwc_ngof   = vng2ftwc  -log_dem_ngof;
    log_p2ptbc_ngof   = vng2ptbc  -log_dem_ngof;
    log_p2ptwc_ngof   = vng2ptwc  -log_dem_ngof;
    log_p2_ngof       = vng2      -log_dem_ngof;
    log_p4sftbc_ngof  = vng4sftbc -log_dem_ngof;
    log_p4sftwc_ngof  = vng4sftwc -log_dem_ngof;
    log_p4sptbc_ngof  = vng4sptbc -log_dem_ngof;
    log_p4sptwc_ngof  = vng4sptwc -log_dem_ngof;
    log_p4s_ngof      = vng4s     -log_dem_ngof;
    log_p4nsftbc_ngof = vng4nsftbc-log_dem_ngof;
    log_p4nsftwc_ngof = vng4nsftwc-log_dem_ngof;
    log_p4nsptbc_ngof = vng4nsptbc-log_dem_ngof;
    log_p4nsptwc_ngof = vng4nsptwc-log_dem_ngof;
    log_p4ns_ngof     = vng4ns    -log_dem_ngof;
    log_pwptbc_ngof   = vngwptbc  -log_dem_ngof;
    log_pwptwc_ngof   = vngwptwc  -log_dem_ngof;
    log_pwftbc_ngof   = vngwftbc  -log_dem_ngof;
    log_pwftwc_ngof   = vngwftwc  -log_dem_ngof;
    log_ph_ngof       =           -log_dem_ngof;
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

    % Part 2a
    log_dem_grno     = log(1+exp(vgwptbc)+exp(vgwftbc));
    log_pwptbc_grno  = vgwptbc-log_dem_grno;
    log_pwftbc_grno  = vgwftbc-log_dem_grno;
    log_ph_grno      =        -log_dem_grno;
    P(grad_4yr==1 & offer==0,[16 18 20]) = cat(2,exp(log_pwptbc_grno (grad_4yr==1 & offer==0)),... %alt 16
                                                 exp(log_pwftbc_grno (grad_4yr==1 & offer==0)),... %alt 18
                                                 exp(log_ph_grno     (grad_4yr==1 & offer==0)));   %alt 20

    % Part 2b
    log_dem_grof     = log(1+exp(vgwptbc)+exp(vgwptwc)+exp(vgwftbc)+exp(vgwftwc));
    log_pwptbc_grof  = vgwptbc-log_dem_grof;
    log_pwptwc_grof  = vgwptwc-log_dem_grof;
    log_pwftbc_grof  = vgwftbc-log_dem_grof;
    log_pwftwc_grof  = vgwftwc-log_dem_grof;
    log_ph_grof      =        -log_dem_grof;
    P(grad_4yr==1 & offer==1,16:20) = cat(2,exp(log_pwptbc_grof (grad_4yr==1 & offer==1)),... %alt 16
                                            exp(log_pwptwc_grof (grad_4yr==1 & offer==1)),... %alt 17
                                            exp(log_pwftbc_grof (grad_4yr==1 & offer==1)),... %alt 18
                                            exp(log_pwftwc_grof (grad_4yr==1 & offer==1)),... %alt 19
                                            exp(log_ph_grof     (grad_4yr==1 & offer==1)));   %alt 20
end 
