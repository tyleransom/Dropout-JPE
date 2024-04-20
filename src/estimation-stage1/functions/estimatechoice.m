function parms = estimatechoice(ecdata,parms,PmajgpaType,test,priorabil)

    abil = [priorabil.prior_ability_S_vec priorabil.prior_ability_U_vec priorabil.prior_ability_4S_vec priorabil.prior_ability_4NS_vec priorabil.prior_ability_2_vec];

    o3=optimset('Disp','final','MaxFunEvals',1e8,'MaxIter',1e8,'GradObj','on','LargeScale','off','TolX',1e-7);
    optccp = optimset('Disp','final','LargeScale','off','GradObj','on','DerivativeCheck','off','MaxIter',1e8,'MaxFunEvals',1e8,'TolX',1e-7);

    if test==true
        optccp = optimset('Disp','iter','LargeScale','off','GradObj','on','DerivativeCheck','on','FunValCheck','off','MaxIter',2,'MaxFunEvals',2,'TolX',1e-5);
        o3=optimset('Disp','iter','FunValCheck','off','MaxFunEvals',2,'MaxIter',2,'GradObj','on','LargeScale','off','TolX',1e-5);
    end


    %------------------------------------------
    % Multinomial logit for college graduates
    %------------------------------------------
    % parameter constraints
    restrMatGrad = zeros(3,5);
    restrMatGrad(1,:) = [20 0 0 0 0];
    restrMatGrad(2,:) = [42 0 0 0 0];
    restrMatGrad(3,:) = [64 0 0 0 0];
    assert(size(restrMatGrad,2)==5,'restrMatGrad must have 5 columns');

    % optimization
    b1 = fminunc('wmlogit_restrict',parms.bgrad,optccp,restrMatGrad,ecdata.ClImps(ecdata.grad_4yrlImps==1 & ecdata.ClImps>=16),ecdata.Xgrad(ecdata.grad_4yrlImps==1 & ecdata.ClImps>=16,:),PmajgpaType(ecdata.grad_4yrlImps==1 & ecdata.ClImps>=16),abil(ecdata.grad_4yrlImps==1 & ecdata.ClImps>=16,:));
    bf = applyRestr(restrMatGrad,b1);
    bgrad = bf;


    %------------------------------------------
    % Logit for non-college graduates
    %------------------------------------------
    % parameter constraints
    restrMatNoGrad = zeros(6,5);
    restrMatNoGrad(1,:) = [27  0 0 0 0];
    restrMatNoGrad(2,:) = [55  0 0 0 0];
    restrMatNoGrad(3,:) = [83  0 0 0 0];
    restrMatNoGrad(4,:) = [110 0 0 0 0];
    restrMatNoGrad(5,:) = [138 0 0 0 0];
    restrMatNoGrad(6,:) = [166 0 0 0 0];
    assert(size(restrMatNoGrad,2)==5,'restrMatNoGrad must have 5 columns');

    % optimization
    b1 = fminunc('wmlogit_restrictU',parms.bnograd(:),o3,restrMatNoGrad,ecdata.ClImps(ecdata.grad_4yrlImps==0 & ecdata.ClImps>0),ecdata.Xw(ecdata.grad_4yrlImps==0 & ecdata.ClImps>0,:),PmajgpaType(ecdata.grad_4yrlImps==0 & ecdata.ClImps>0),abil(ecdata.grad_4yrlImps==0 & ecdata.ClImps>0,:));
    bf = applyRestr(restrMatNoGrad,b1);
    bnograd = bf;


    % store outputs
    parms  = v2struct(bgrad,bnograd);
end
