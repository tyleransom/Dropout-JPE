function [vNG,vG]=consumpsearchstruc_condvalfns(b,Y,lambda,ut,grad_4yr,AdjNG,AdjG,sdemog,S,q)

    in_white_collar = ismember(Y,[2 4 7 9 12 14 17 19]);
    prev_WC         = ut.sprevs(:,end);

    b2flg   = 1+[1:ut.number2];
    b4sflg  = 1+[1+ut.number2:ut.number2+ut.number4s];
    b4nsflg = 1+[1+ut.number2+ut.number4s:ut.number2+ut.number4s+ut.number4ns];
    bwptflg = 1+[1+ut.number2+ut.number4s+ut.number4ns:ut.number2+ut.number4s+ut.number4ns+ut.numberpt];
    bwftflg = 1+[1+ut.number2+ut.number4s+ut.number4ns+ut.numberpt:ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft];
    bwcflg  = 1+[1+ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft:ut.number2+ut.number4s+ut.number4ns+ut.numberpt+ut.numberft+ut.numberwc];

    alpha     = b(1);
    b2        = b(b2flg);
    b2temp    = [b2(1:sdemog+1);0;b2(sdemog+2:end-7);0;0;b2(end-6:end)];% two 0s: grad_4yr, white_collar
    b2tflg    = find(b2temp~=0);
    b4s       = b(b4sflg);
    b4stemp   = [b4s(1:sdemog+1);0;b4s(sdemog+2:end-7);0;0;b4s(end-6:end)];
    b4stflg   = find(b4stemp~=0);
    b4ns      = b(b4nsflg);
    b4nstemp  = [b4ns(1:sdemog+1);0;b4ns(sdemog+2:end-7);0;0;b4ns(end-6:end)];
    b4nstflg  = find(b4nstemp~=0);
    bwpt      = b(bwptflg);
    bwpttemp  = [bwpt(1:sdemog);0;0;bwpt(sdemog+1:end-3);0;0;0;0;bwpt(end-2:end)];% only four 0s here bc need to estimate white_collar parameter
    bwpttflg  = find(bwpttemp~=0);
    bwft      = b(bwftflg);
    bwfttemp  = [bwft(1:sdemog);0;0;bwft(sdemog+1:end-3);0;0;0;0;0;bwft(end-2:end)];
    bwfttflg  = find(bwfttemp~=0);
    bwc       = b(bwcflg);
    bwctemp   = [bwc(1:sdemog);0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];
    bwctflg   = find(bwctemp~=0);

    % indices to flag consumption and non-consumption covariates in matrices
    cidx      = sdemog+2;

    % "utility" for 2-year college:
    vng2ftbc = (ut.X2ftbc*(b2temp+bwfttemp        )+ut.X2ftbc(:,cidx)*alpha)+AdjNG(:,1);
    vng2ftwc = (ut.X2ftwc*(b2temp+bwfttemp+bwctemp)+ut.X2ftwc(:,cidx)*alpha)+AdjNG(:,2);
    vng2ptbc = (ut.X2ptbc*(b2temp+bwpttemp        )+ut.X2ptbc(:,cidx)*alpha)+AdjNG(:,3);
    vng2ptwc = (ut.X2ptwc*(b2temp+bwpttemp+bwctemp)+ut.X2ptwc(:,cidx)*alpha)+AdjNG(:,4);
    vng2     = (ut.X2nw*  (b2temp                 )+ut.X2nw(  :,cidx)*alpha)+AdjNG(:,5);

    % "utility" for 4-year college: Science majors
    vng4sftbc = (ut.X4sftbc*(b4stemp+bwfttemp        )+ut.X4sftbc(:,cidx)*alpha)+AdjNG(:,6);
    vng4sftwc = (ut.X4sftwc*(b4stemp+bwfttemp+bwctemp)+ut.X4sftwc(:,cidx)*alpha)+AdjNG(:,7);
    vng4sptbc = (ut.X4sptbc*(b4stemp+bwpttemp        )+ut.X4sptbc(:,cidx)*alpha)+AdjNG(:,8);
    vng4sptwc = (ut.X4sptwc*(b4stemp+bwpttemp+bwctemp)+ut.X4sptwc(:,cidx)*alpha)+AdjNG(:,9);
    vng4s     = (ut.X4snw  *(b4stemp                 )+ut.X4snw(  :,cidx)*alpha)+AdjNG(:,10);

    % Non-Science majors
    vng4nsftbc = (ut.X4nsftbc*(b4nstemp+bwfttemp        )+ut.X4nsftbc(:,cidx)*alpha)+AdjNG(:,11);
    vng4nsftwc = (ut.X4nsftwc*(b4nstemp+bwfttemp+bwctemp)+ut.X4nsftwc(:,cidx)*alpha)+AdjNG(:,12);
    vng4nsptbc = (ut.X4nsptbc*(b4nstemp+bwpttemp        )+ut.X4nsptbc(:,cidx)*alpha)+AdjNG(:,13);
    vng4nsptwc = (ut.X4nsptwc*(b4nstemp+bwpttemp+bwctemp)+ut.X4nsptwc(:,cidx)*alpha)+AdjNG(:,14);
    vng4ns     = (ut.X4nsnw  *(b4nstemp                 )+ut.X4nsnw(  :,cidx)*alpha)+AdjNG(:,15);

    % "utility" for working
    vngwptbc = (ut.Xngwptbc*(bwpttemp        )+ut.Xngwptbc(:,cidx)*alpha)+AdjNG(:,16);
    vngwptwc = (ut.Xngwptwc*(bwpttemp+bwctemp)+ut.Xngwptwc(:,cidx)*alpha)+AdjNG(:,17);
    vngwftbc = (ut.Xngwftbc*(bwfttemp        )+ut.Xngwftbc(:,cidx)*alpha)+AdjNG(:,18);
    vngwftwc = (ut.Xngwftwc*(bwfttemp+bwctemp)+ut.Xngwftwc(:,cidx)*alpha)+AdjNG(:,19);

    % "utility" for grad school 
    vgwptbc = (ut.Xgwptbc*(bwpttemp                )+ut.Xgwptbc( :,cidx)*alpha)+AdjG(:,16);
    vgwptwc = (ut.Xgwptwc*(bwpttemp+bwctemp        )+ut.Xgwptwc( :,cidx)*alpha)+AdjG(:,17);
    vgwftbc = (ut.Xgwftbc*(bwfttemp                )+ut.Xgwftbc( :,cidx)*alpha)+AdjG(:,18);
    vgwftwc = (ut.Xgwftwc*(bwfttemp+bwctemp        )+ut.Xgwftwc( :,cidx)*alpha)+AdjG(:,19);

    vNG = cat(2, vng2ftbc, vng2ftwc, vng2ptbc, vng2ptwc, vng2, vng4sftbc, vng4sftwc, vng4sptbc, vng4sptwc, vng4s, vng4nsftbc, vng4nsftwc, vng4nsptbc, vng4nsptwc, vng4ns, vngwptbc, vngwptwc, vngwftbc, vngwftwc, zeros(size(vngwftwc)));
    vG  = cat(2, vgwptbc, vgwptwc, vgwftbc, vgwftwc, zeros(size(vgwftwc)));
end 
