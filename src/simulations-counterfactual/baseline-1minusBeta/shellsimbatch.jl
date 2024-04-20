using Random, DataFrames, LinearAlgebra, Statistics, StatsBase, Distributions, MAT, GLM, InteractiveUtils, SpecialFunctions, CSV, DelimitedFiles, QuadGK

include("allfuns.jl")

@views @inbounds function loadparams(f0,f1,f2,f3)
    # Load in parameters from estimation files
    file = matopen(f0)
        πτ = read(file,"prior")
    close(file)
    file = matopen(f1)
        dataStruct       = read(file,"dataStruct")
        AR1parms         = read(file,"AR1parms")
        S                = Int(read(file,"S"))
        searchparms      = read(file,"searchparms")
        learnparms       = read(file,"learnparms")
        gradparms        = read(file,"gradparms")
        Clb              = read(file,"Clb")
        CRRA             = read(file,"CRRA")
    close(file)
    file = matopen(f2)
        cmap_nograd        = read(file,"cmap_nograd")
        cmap_nograd_work   = read(file,"cmap_nograd_work")
        cmap_grad_work     = read(file,"cmap_grad_work")
        scaler_nograd      = read(file,"scaler_nograd")
        scaler_nograd_work = read(file,"scaler_nograd_work")
        scaler_grad_work   = read(file,"scaler_grad_work")
    close(file)
    cmapParms = (cmap_nograd = cmap_nograd, cmap_nograd_work = cmap_nograd_work, cmap_grad_work = cmap_grad_work, scaler_nograd = scaler_nograd, scaler_nograd_work = scaler_nograd_work, scaler_grad_work = scaler_grad_work)
    file = matopen(f3)
        strucparms = read(file,"strucparms")
    close(file)

    # force covariance matrix to be symmetric (it is numerically but not perfectly symmetric)
    learnparms["Delta"] = tril(learnparms["Delta"],-1)+tril(learnparms["Delta"],-1)'+Diagonal(learnparms["Delta"])
    # re-index covariance matrix to: 2yr (5), 4yrsci (3), 4yrhum (4), white collar (1), blue collar (2)
    Δ = copy(learnparms["Delta"][[5, 3, 4, 1, 2],[5, 3, 4, 1, 2]])
    # idiosyncratic variances from learning
    σ = vcat(learnparms["sig"][1],learnparms["lambdag1start"]^2*learnparms["sig"][2],learnparms["sig"][3],learnparms["lambdan1start"]^2*learnparms["sig"][4],learnparms["sig"][5:6],(learnparms["lambda4s1start"]^2).*learnparms["sig"][7:9],learnparms["sig"][10:11],(learnparms["lambda4h1start"]^2).*learnparms["sig"][12:14],learnparms["sig"][15:17])

    # time horizon parameters
    β=0.9                 # discount factor
    intrate=0.05          # interest rate on debt repayment
    numgrid=4             # number of grid points in integral over future labor market conditions
    T=65-17               # retirement age [subtract 17 since age 18 corresponds to 0]
    T1=min(10,T)          # able-to-choose-college time horizon
    TR=min(20,T)          # when start repaying debt
    debthorizon=min(20,T) # time horizon to repay debt
    D=10                  # replications per person
    numdraws=2_000        # replications per person
    CapSug=min(20,T)      # limit on amount of white collar experience (in half-year units) for non-grads; max in data is 9 years [but T1 is 10 years]
    CapS=min(30,T)        # limit on amount of white collar experience (in half-year units) for grads; max in data is 9 years [but T1 is 10 years]
    CapTot=min(30,T)      # limit on amount of total experience (in half-year units) for grads; max in data is 9 years [but T1 is 10 years]
    CapU=min(30,T)        # limit on amount of blue  collar experience (in half-year units); max in data is 13 years [but T1 is 10 years]
    Cap2=4                # limit on amount of cumulative 2yr college; max in data is 7 years (99th percentile is 4 years)
    Cap4=6                # limit on amount of cumulative 4yr college;  max in data is 9 years (99th percentile is 6 years)
    CapCTot=7             # limit on amount of total schooling; max in data is 9 years [but T1 is 10 years]

    # create AR(1) Markov transition matrix for labor market conditions
    pistba, pimba = mytauchen(0,AR1parms["rhoU"],AR1parms["unsk_wage_sig"],numgrid)

    # named tuple holding all parameter values
    allp = (
            S                    = S,                                    #no. of unobs. types
            β                    = β,                                    #discount factor
            πτ                   = πτ,                                   #unobserved type probabilities
            Δ                    = Δ,                                    #ability correlation matrix
            σ                    = σ,                                    #idiosyncratic variances of learning outcomes
            intrate              = intrate,                              #loan repayment interest rate
            Clb                  = Clb,                                  #consumption lower bound
            CRRA                 = CRRA,                                 #CRRA parameter
            bstruc               = strucparms["bstrucstruc"][:,1],       #structural flow utility parameters
            bgrad                = gradparms["P_grad_betas4"][:,1],      #P(grad 4yr) logit params
            boffer               = searchparms["boffer"][:,1],           #P(WC offer) logit params
            cmapParms            = cmapParms,                            #E(u(C)) polynomial params
            bstartn              = learnparms["bstartn"][:,1],           #BC wage parameters
            bstartg              = learnparms["bstartg"][:,1],           #WC wage parameters
            unskilledWageBeta_a  = AR1parms["unskilledWageBeta_a"][:,1], #BC wage parameters with yr dummies pushed forward 1 period 
            skilledWageBeta_a    = AR1parms["skilledWageBeta_a"][:,1],   #WC wage parameters with yr dummies pushed forward 1 period
            unskilledWageBetaMat = AR1parms["unskilledWageBetaMat"],     #BC wage parameters with yr dummies pushed forward p periods
            skilledWageBetaMat   = AR1parms["skilledWageBetaMat"],       #WC wage parameters with yr dummies pushed forward p periods
            lambdan0start        = learnparms["lambdan0start"],          #BC lambda0
            lambdag0start        = learnparms["lambdag0start"],          #WC lambda0
            lambdan1start        = learnparms["lambdan1start"],          #BC lambda1
            lambdag1start        = learnparms["lambdag1start"],          #WC lambda1
            lambdaydgstart       = learnparms["lambdaydgstart"],         #lambda on year dummies in WC sector
            sdemog               = 10,                                   #number of demographic variables in structural flow utility
            pistb                = pistba,                               #aggr. labor market states
            pimb                 = pimba,                                #aggr. labor market state transition matrix
            numgrid              = numgrid,                              #number of grid points in integral over future labor market conditions
            T                    = T,                                    #retirement age
            T1                   = T1,                                   #able-to-choose-college time horizon
            TR                   = TR,                                   #time period when loans become due
            debthorizon          = debthorizon,                          #no. of years to repay college debt
            D                    = D,                                    #replications per person
            CapSug               = CapSug,                               #limit on amount of white collar experience (in half-year units) for non-grads
            CapS                 = CapS,                                 #limit on amount of white collar experience (in half-year units) for grads
            CapTot               = CapTot,                               #limit on amount of total experience (in half-year units) for anyone
            CapU                 = CapU,                                 #limit on amount of blue  collar experience (in half-year units) for anyone
            Cap2                 = Cap2,                                 #limit on amount of cumulative 2yr college
            Cap4                 = Cap4,                                 #limit on amount of cumulative 4yr college
            CapCTot              = CapCTot                               #limit on amount of total schooling
           )

    # 2. Initialize state variables (no experience)
    # Read in demographic variables ((N*T)x1 vectors)
    dataStruct["T"] = Int(dataStruct["T"])
    dataStruct["N"] = Int(dataStruct["N"])
    dataStruct["HS_gradesw"] = Array(reshape(dataStruct["HS_grades"],dataStruct["T"],dataStruct["N"])')
    dataStruct["HS_gradesw"] = dataStruct["HS_gradesw"][:,1]
    dataStruct["anyFlagw"]   = Array(reshape(dataStruct["anyFlag"],dataStruct["T"],dataStruct["N"])')
    demog                    = [dataStruct["blackw"] dataStruct["hispanicw"] dataStruct["HS_gradesw"] dataStruct["Parent_collegew"] dataStruct["birthYrw"] dataStruct["famIncw"]]
    flagly                   = any(dataStruct["anyFlagw"].==0, dims=2)

    # Reshape the consumption input data
    tui4imp       = Array(reshape(dataStruct["tui4imp"]      ,dataStruct["T"],dataStruct["N"])')
    grant4pr      = Array(reshape(dataStruct["grant4pr"]     ,dataStruct["T"],dataStruct["N"])')
    loan4pr       = Array(reshape(dataStruct["loan4pr"]      ,dataStruct["T"],dataStruct["N"])')
    grant4RMSE    = Array(reshape(dataStruct["grant4RMSE"]   ,dataStruct["T"],dataStruct["N"])')
    loan4RMSE     = Array(reshape(dataStruct["loan4RMSE"]    ,dataStruct["T"],dataStruct["N"])')
    grant4idx     = Array(reshape(dataStruct["grant4idx"]    ,dataStruct["T"],dataStruct["N"])')
    loan4idx      = Array(reshape(dataStruct["loan4idx"]     ,dataStruct["T"],dataStruct["N"])')
    tui2imp       = Array(reshape(dataStruct["tui2imp"]      ,dataStruct["T"],dataStruct["N"])')
    grant2pr      = Array(reshape(dataStruct["grant2pr"]     ,dataStruct["T"],dataStruct["N"])')
    loan2pr       = Array(reshape(dataStruct["loan2pr"]      ,dataStruct["T"],dataStruct["N"])')
    grant2RMSE    = Array(reshape(dataStruct["grant2RMSE"]   ,dataStruct["T"],dataStruct["N"])')
    loan2RMSE     = Array(reshape(dataStruct["loan2RMSE"]    ,dataStruct["T"],dataStruct["N"])')
    grant2idx     = Array(reshape(dataStruct["grant2idx"]    ,dataStruct["T"],dataStruct["N"])')
    loan2idx      = Array(reshape(dataStruct["loan2idx"]     ,dataStruct["T"],dataStruct["N"])')
    ParTrans2RMSE = Array(reshape(dataStruct["ParTrans2RMSE"],dataStruct["T"],dataStruct["N"])')
    ParTrans4RMSE = Array(reshape(dataStruct["ParTrans4RMSE"],dataStruct["T"],dataStruct["N"])')
    E_loan4_18    = Array(reshape(dataStruct["E_loan4_18"]   ,dataStruct["T"],dataStruct["N"])')
    E_loan2_18    = Array(reshape(dataStruct["E_loan2_18"]   ,dataStruct["T"],dataStruct["N"])')
    lnFamInc      = Array(reshape(dataStruct["lnFamInc"]     ,dataStruct["T"],dataStruct["N"])')
    fastconsump = ( # named tuple
                   tui4imp       = tui4imp[vec(flagly),1],
                   grant4pr      = grant4pr[vec(flagly),1],
                   loan4pr       = loan4pr[vec(flagly),1],
                   grant4RMSE    = grant4RMSE[vec(flagly),1],
                   loan4RMSE     = loan4RMSE[vec(flagly),1],
                   grant4idx     = grant4idx[vec(flagly),1],
                   loan4idx      = loan4idx[vec(flagly),1],
                   tui2imp       = tui2imp[vec(flagly),1],
                   grant2pr      = grant2pr[vec(flagly),1],
                   loan2pr       = loan2pr[vec(flagly),1],
                   grant2RMSE    = grant2RMSE[vec(flagly),1],
                   loan2RMSE     = loan2RMSE[vec(flagly),1],
                   grant2idx     = grant2idx[vec(flagly),1],
                   loan2idx      = loan2idx[vec(flagly),1],
                   ParTrans2RMSE = ParTrans2RMSE[vec(flagly),1],
                   ParTrans4RMSE = ParTrans4RMSE[vec(flagly),1],
                   E_loan4_18    = E_loan4_18[vec(flagly),1],
                   E_loan2_18    = E_loan2_18[vec(flagly),1],
                   lnFamInc      = lnFamInc[vec(flagly),1],
                   loanrepay     = zeros(size(lnFamInc[vec(flagly),1])) ,
                   numdraws      = numdraws*ones(size(lnFamInc[vec(flagly),1])) #number of draws for consumption MC integral
    )
    obsvbls = demog[vec(flagly),:] # collapse duplicates
    N       = size(obsvbls,1)
    @assert N==2300 "Wrong N!"
    return obsvbls,fastconsump,allp
end

@views @inbounds function shell()
    iii = parse(Int,ENV["SLURM_ARRAY_TASK_ID"])
    Random.seed!(iii+1_000)
    
    final = DataFrame()
    # loop over individuals
    for i=iii
        fn0 = "../../../output/all-stage-1/everything_all_stage1_interact_type_36688212.mat"
        fn1 = "../../../output/utility/everything_jointsearch_WCabsorb37595330.mat"
        fn2 = "../../../output/utility/cmapoutput_perf_info.mat"
        fn3 = "../../../output/utility/everything_consumpstructural_FVfast39374622.mat"
        obsvbls,fastconsump,allParms = loadparams(fn0,fn1,fn2,fn3)
        for d=1:allParms.D
            PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,PChoicew,PChoiceb,PGrad,ab_vec,utypevec,demogi = innerloop(i,obsvbls,fastconsump,allParms) 
            Yvec,gradvec,LYvec,offer,lmtile = forwardsim(PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,PChoicew,PChoiceb,PGrad,utypevec,allParms)
            println("Done with forward sim for draw ",d)
            tempo = DataFrame(
                              simno      = d,
                              choice1    = Yvec[1],
                              choice2    = Yvec[2],
                              choice3    = Yvec[3],
                              choice4    = Yvec[4],
                              choice5    = Yvec[5],
                              choice6    = Yvec[6],
                              choice7    = Yvec[7],
                              choice8    = Yvec[8],
                              choice9    = Yvec[9],
                              choice10   = Yvec[10],
                              lmstate1   = lmtile[1],
                              lmstate2   = lmtile[2],
                              lmstate3   = lmtile[3],
                              lmstate4   = lmtile[4],
                              lmstate5   = lmtile[5],
                              lmstate6   = lmtile[6],
                              lmstate7   = lmtile[7],
                              lmstate8   = lmtile[8],
                              lmstate9   = lmtile[9],
                              lmstate10  = lmtile[10],
                              WCoffer1   = offer[1],
                              WCoffer2   = offer[2],
                              WCoffer3   = offer[3],
                              WCoffer4   = offer[4],
                              WCoffer5   = offer[5],
                              WCoffer6   = offer[6],
                              WCoffer7   = offer[7],
                              WCoffer8   = offer[8],
                              WCoffer9   = offer[9],
                              WCoffer10  = offer[10],
                              grad_4yr1  = gradvec[1],
                              grad_4yr2  = gradvec[2],
                              grad_4yr3  = gradvec[3],
                              grad_4yr4  = gradvec[4],
                              grad_4yr5  = gradvec[5],
                              grad_4yr6  = gradvec[6],
                              grad_4yr7  = gradvec[7],
                              grad_4yr8  = gradvec[8],
                              grad_4yr9  = gradvec[9],
                              grad_4yr10 = gradvec[10],
                              unobtype   = utypevec,
                              abil1      = ab_vec[1],
                              abil2      = ab_vec[2],
                              abil3      = ab_vec[3],
                              abil4      = ab_vec[4],
                              abil5      = ab_vec[5],
                              black      = demogi[2],
                              hispanic   = demogi[3],
                              HS_GPA     = demogi[4],
                              Parent_col = demogi[5],
                              birthYr    = demogi[6],
                              famInc     = demogi[7]
                             )
            final = vcat(final,tempo)
            Base.GC.gc(true) # execute garbage collector in hopes that this will reduce out-of-memory issues
        end
        CSV.write(string("../../../output/cfl/baseline-1minusBeta/CflData",i,".csv") , final)
    end
    return nothing
end

shell()

