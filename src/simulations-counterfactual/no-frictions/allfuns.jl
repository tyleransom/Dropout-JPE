# function to print memory usage of object x in MB
function summarysize_mb(x)
    mb::Float64 = Base.summarysize(x) / ( 1024 * 1024 )
    return mb::Float64
end

# function to print memory usage of object x in GB
function summarysize_gb(x)
    gb::Float64 = Base.summarysize(x) / ( 1024 * 1024 * 1024 )
    return gb::Float64
end

# function to get memory usage at any point in time
function get_mem_use()
    f::IOStream         = open( "/proc/self/stat", "r" )
    s::AbstractString   = read( f, String )
    vsize::Int          = parse( Int64, split( s )[23] )
    mb::Int             = Int( ceil( vsize / ( 1024 * 1024 ) ) )
    gb::Float64         = mb / ( 1024 )
    close(f)
    return gb::Float64
end

@views @inbounds begin
"""
    abildrawer(Δ)

This function draws (once) from a mean-0 MvNormal distribution with covariance Δ

"""
function abildrawer(Δ)
    abil = rand(MvNormal(zeros(size(Δ,1)),Δ))
    return abil
end


"""
    choicedrawer(P,bcidx,offer)

This function draws (once) from an unordered probability mass function with mass vector P. 
    bcidx indicates alternatives that have non-zero mass when offer==0. 
    When offer==1, all alternatives have positive mass.

"""
function choicedrawer(P,offer,bcidx)
    draw = rand()
    Y    = 0
    Yno  = 0
    Yo   = 0
    J    = length(P)
    for j in bcidx
        Ytemp = draw<sum(P[j:end])
        Yno+=Ytemp
    end
    for j in 1:J
        Ytemp = draw<sum(P[j:end])
        Yo+=Ytemp
    end
    Yno = bcidx[Yno]
    Y = Yno*(offer==0)+Yo*(offer==1)
    # error checking
    @assert !isequal(P,zeros(J)) && !any(isnan.(P)) "Choice generation error: P is either all 0 or has NaN elements."
    @assert in(Y,1:J) "Choice generation error: Y is outside of the set {1, ..., J}.\n This is likely due to an indexing error in P"
    return Y
end


"""
    lmdrawer(Σ,g)

This function updates the current labor market shock state (indexed by g) according to Markov transition matrix Σ

"""
function lmdrawer(Σ,g)
    lmdraw  = rand()
    lmt     = 0
    numgrid = size(Σ,2)
    for k=1:numgrid
        lmtemp = lmdraw<sum(Σ[convert(Int,g),k:end])
        lmt+=lmtemp
    end
    @assert in(lmt,1:numgrid)
    return lmt
end


"""
    typedrawer(ψ)

This function draws (once) from an unordered probability mass function with mass vector ψ

"""
function typedrawer(ψ)
    draw = rand()
    stype = 0
    for s=1:length(ψ)
        temp  = (draw<sum(ψ[s:end]))
        stype += temp
    end
    return stype
end


"""
    state_update(Y,gr,eS,eU,c4,c2,lmtile,PGrad,p)

This function updates the future states based on current-period choices

Inputs are:
Y: current choice
gr: current graduation status
eS: current level of white collar experience
eU: current level of blue collar experience
c4: current level of 4yr college experience
c2: current level of 2yr college experience
lmtile: current aggregate labor market shock quantile
PGrad: matrix of state-contingent graduation probabilities
p: NamedTuple containing all parameters of the simulation

"""
function state_update(Y,gr,eS,eU,c4::Int64,c2::Int64,lmtile,PGrad,p)
    pimb     = p.pimb
    CapU     = p.CapU
    Cap4     = p.Cap4
    Cap2     = p.Cap2
    CapTot   = p.CapTot
    CapCTot  = p.CapCTot
    if gr==1
        CapS = p.CapS
    else
        CapS = p.CapSug
    end

    # set up indices
    wcgidx   = [2 4]
    bcgidx   = [1 3]
    wcgptidx = [4]
    bcgptidx = [3]
    wcgftidx = setdiff(wcgidx,wcgptidx)
    bcgftidx = setdiff(bcgidx,bcgptidx)
    wcidx    = [2 4 7 9 12 14 17 19]
    bcidx    = [1 3 6 8 11 13 16 18]
    wcptidx  = [4 9 14 17]
    bcptidx  = [3 8 13 16]
    wcftidx  = setdiff(wcidx,wcptidx)
    bcftidx  = setdiff(bcidx,bcptidx)

    # t+1 values of lagged graduation and lagged choice are just the period-t values
    newLgr = gr
    newLY  = Y
    # update experience variables, keeping in mind the caps on the state space
    neweS = deepcopy(eS)
    neweU = deepcopy(eU)
    newc4 = deepcopy(c4)
    newc2 = deepcopy(c2)
    # convert work experience caps to annual basis
    anCapS   = CapS  /2
    anCapU   = CapU  /2
    anCapTot = CapTot/2
    # part-time white collar
    if ( any(in.(Y,wcptidx)) && gr==0 ) || ( any(in.(Y,wcgptidx)) && gr==1 )
        neweS += 0.5
        if (neweS ≥ anCapS) || ((neweS+neweU) ≥ anCapTot)
            neweS = min( min(neweS, anCapS), min(neweS, anCapTot-neweU) ) 
        end
    end
    # full-time white collar
    if ( any(in.(Y,wcftidx)) && gr==0 ) || ( any(in.(Y,wcgftidx)) && gr==1 ) 
        neweS += 1
        if (neweS ≥ anCapS) || ((neweS+neweU) ≥ anCapTot)
            neweS = min( min(neweS, anCapS), min(neweS, anCapTot-neweU) ) 
        end
    end
    # part-time blue collar
    if ( any(in.(Y,bcptidx)) && gr==0 ) || ( any(in.(Y,bcgptidx)) && gr==1 ) 
        neweU += 0.5
        if (neweU ≥ anCapU) || ((neweU+neweS) ≥ anCapTot)
            neweU = min( min(neweU, anCapU), min(neweU, anCapTot-neweS) )
        end
    end
    # full-time blue collar
    if ( any(in.(Y,bcftidx)) && gr==0 ) || ( any(in.(Y,bcgftidx)) && gr==1 ) 
        neweU += 1
        if (neweU ≥ anCapU) || ((neweU+neweS) ≥ anCapTot)
            neweU = min( min(neweU, anCapU), min(neweU, anCapTot-neweS) )
        end
    end
    # 4yr 
    if any(in.(Y,6:15)) && gr==0
        newc4 += 1
        if (newc4 ≥ Cap4) || ((newc4+newc2) ≥ CapCTot)
            newc4 = min( min(newc4, Cap4), min(newc4, CapCTot-newc2) )
        end
    end
    # 2yr 
    if any(in.(Y,1:5)) && gr==0
        newc2 += 1
        if (newc2 ≥ Cap2) || ((newc4+newc2) ≥ CapCTot)
            newc2 = min( min(newc2, Cap2), min(newc2, CapCTot-newc4) )
        end
    end
    # update graduation status
    if gr==1
        newgr = 1 # graduation is an absorbing state
    else
        newgr = rand()<PGrad[convert(Int,Y),c4+1,c2+1] # draw grad status given probabilities 
    end
    # update labor market shock quantile using the markov transition matrix
    newlmtile = lmdrawer(pimb,lmtile)
    return neweS,neweU,newc4,newc2,newgr,newLgr,newlmtile,newLY
end


"""
    cdf_normal(x)

This function evaluates the CDF of the standard normal distribution at x

"""

function cdf_normal(x)
    c = 0.5 * erfc(-x/sqrt(2))
    return c
end


"""
    mytauchen(mu,rho,sig,N)

This function discretizes a continuous AR(1) process by using the method
proposed by Tauchen (1986). The AR(1) process takes the following form:
y(t) = mu + rho*y(t-1) + eps(t), where eps ~ N(0,sig^2)
Parts of the code are taken from the function tauchen.m written by Martin
Flodén.

INPUTS
   mu:     scalar, intercept term of the AR(1) process
   rho:    scalar, AR-coefficient
   sig:    scalar, standard deviation of innovations
   N:      scalar, number of grid points for the discretized process

OUTPUTS
   s:      column vector of size Nx1, contains all possible states in ascending order
   Pi:     matrix of size NxN, contains the transition proabilities. Rows
           are current state and columns future state

Author:   Jan Hannes Lang
Date:     6.7.2010

Julia adaptation (from Matlab) by Tyler Ransom (16.4.2021)

"""

function mytauchen(mu,rho,sig,N)
    m    = 3
    s    = zeros(N)
    Pi   = zeros(N,N)
    s[1] = mu/(1-rho) - m*sqrt(sig^2/(1-rho^2))
    s[N] = mu/(1-rho) + m*sqrt(sig^2/(1-rho^2))
    step = (s[N]-s[1])/(N-1)

    for i = 2:(N-1)
        s[i] = s[i-1] + step
    end

    for j = 1:N
        for k = 1:N
            if k == 1
                Pi[j,k] = cdf_normal((s[1] - mu - rho*s[j] + step/2) / sig)
            elseif k == N
                Pi[j,k] = 1 - cdf_normal((s[N] - mu - rho*s[j] - step/2) / sig)
            else
                Pi[j,k] = cdf_normal((s[k] - mu - rho*s[j] + step/2) / sig) - cdf_normal((s[k] - mu - rho*s[j] - step/2) / sig)
            end
        end
    end
    return s, Pi
end


"""
    amortization(principal, interest, horizon)

This function computes an annual payment based on an amortization of a
loan of amount PRINCIPAL with annual interest rate INTEREST over a time horizon
HORIZON. The function assumes that (anual interest divided by 12) is compounded monthly. It
returns an annual payment (i.e. monthly payments * 12)

This function is meant to take scalars as inputs, but will also accept
vector inputs, so long as the vectors are all of the same dimension

Source: Amortization Calculator (Bankrate.com)
URL: https://www.bankrate.com/calculators/mortgages/amortization-calculator.aspx
Accessed: Feb 2021

"""
function amortization(principal,interest,horizon)

    interest = interest./12  # convert annual interest rate to monthly interest rate
    horizon  = horizon.*12   # number of payments (months)
    pmt      = 12 .* principal .* (interest.*(1 .+ interest).^horizon)./(((1 .+ interest).^horizon) .- 1) # multiply by 12 to get annual payment
    return pmt
end


"""
    getParTransIdx(X, state, inputs, sector)

This function computes the level of parental transfers given individual
characteristics X, state variables of the simulation STATE, consumption
inputs INPUTS, and college sector SECTOR.

X must be a vector with 2nd element equal to a dummy for Black and
3rd element equal to a dummy for Hispanic

"""
function getParTransIdx(Xfx,stte,fastCons,sector)
    if sector==4
        b = [8.357448; -.0955420; .1104414; .0027407; .0903884; .1878193] # parameter estimates from Stata
    elseif sector==2
        b = [8.652486; -.0595774; .0334340; .0311122;-.0200760; .0910101] # parameter estimates from Stata
    end
    X = [1 stte.age fastCons.lnFamInc stte.cum_2yr+stte.cum_4yr Xfx[2] Xfx[3]]
    ptidx = X*b
    return ptidx[1]
end



"""
    getParTransPr(Xfx, state, inputs, sector)

This function computes the probability of receiving positive parental transfers
given individual characteristics X, state variables of the simulation STATE,
consumption inputs INPUTS, and college sector SECTOR.

Xfx must be a vector with 2nd element equal to a dummy for Black and
3rd element equal to a dummy for Hispanic

"""
function getParTransPr(Xfx,stte,fastCons,sector)
    if sector==4
        b = [1.701702; -.3316555; .1240221;  .2617838; .1667502] # parameter estimates from Stata
    elseif sector==2
        b = [1.627587; -.3034261; .1539419; -.0397682; .1832065] # parameter estimates from Stata
    end
    X = [1 stte.age fastCons.lnFamInc Xfx[2] Xfx[3]]
    ptpr = exp.(X*b)./(1 .+ exp.(X*b))
    return ptpr[1]
end



"""
    predconsump(j,gr,b1,b2,b3,consumpNaive,gr2yrpridx,gr4yrpridx,gr2yridx,gr4yridx,pt2yrpridx,pt4yrpridx,pt2yridx,pt4yridx,eloan2,eloan4)

This function computes expected consumption by polynomial prediction given the inputs

Inputs are:
j: choice alternative
gr: graduation status
b1: parameters from the consumption mapping (for school choices)
b2: parameters from the consumption mapping (for non-grad work choices)
b3: parameters from the consumption mapping (for grad work choices)
sclr:  scale on consumption to eliminate numerical imprecision (for school choices)
sclr2: scale on consumption to eliminate numerical imprecision (for non-grad work choices)
sclr3: scale on consumption to eliminate numerical imprecision (for grad work choices)
consumpNaive: consumption measure that ignores nonlinearities
gr2yrpridx: probability of positive grants in 2yr college
gr4yrpridx: probability of positive grants in 4yr college
gr2yridx: amount of grants in 2yr college
gr4yridx: amount of grants in 4yr college
pt2yrpridx: probability of positive parental transfers in 2yr college
pt4yrpridx: probability of positive parental transfers in 4yr college
pt2yridx: amount of parental transfers (conditional on positive) in 2yr college
pt4yridx: amount of parental transfers (conditional on positive) in 4yr college
eloan2: expected annual loan amount in 2yr college
eloan4: expected annual loan amount in 4yr college

"""
function predconsump(j,gr,b1,b2,b3,sclr,sclr2,sclr3,consumpNaive,gr2yrpridx,gr4yrpridx,gr2yridx,gr4yridx,pt2yrpridx,pt4yrpridx,pt2yridx,pt4yridx,eloan2,eloan4)
    if any(in.(j,[20]))
        consump = consumpNaive
    elseif any(in.(j,1:5))
        cn = consumpNaive*sclr[j]
        gr2yridx  /= 10000
        pt2yridx   = exp(pt2yridx)/10000
        eloan2    /= 10000
        x = [ones(size(cn)) cn cn^2 cn*gr2yrpridx cn*gr2yridx cn*pt2yrpridx cn*pt2yridx cn*eloan2 gr2yrpridx gr2yrpridx^2 gr2yrpridx*gr2yridx pt2yrpridx*gr2yrpridx pt2yridx*gr2yrpridx eloan2*gr2yrpridx gr2yridx gr2yridx^2 pt2yrpridx*gr2yridx pt2yridx*gr2yridx eloan2*gr2yridx pt2yrpridx pt2yrpridx^2 pt2yridx*pt2yrpridx eloan2*pt2yrpridx pt2yridx pt2yridx^2 eloan2*pt2yridx eloan2 eloan2^2]
        consump = x⋅b1[:,j]
        consump /= sclr[j]
    elseif any(in.(j,6:15))
        cn = consumpNaive*sclr[j]
        gr4yridx  /= 10000
        pt4yridx   = exp(pt4yridx)/10000
        eloan4    /= 10000
        x = [ones(size(cn)) cn cn^2 cn*gr4yrpridx cn*gr4yridx cn*pt4yrpridx cn*pt4yridx cn*eloan4 gr4yrpridx gr4yrpridx^2 gr4yrpridx*gr4yridx pt4yrpridx*gr4yrpridx pt4yridx*gr4yrpridx eloan4*gr4yrpridx gr4yridx gr4yridx^2 pt4yrpridx*gr4yridx pt4yridx*gr4yridx eloan4*gr4yridx pt4yrpridx pt4yrpridx^2 pt4yridx*pt4yrpridx eloan4*pt4yrpridx pt4yridx pt4yridx^2 eloan4*pt4yridx eloan4 eloan4^2]
        consump = x⋅b1[:,j]
        consump /= sclr[j]
    elseif any(in.(j,16:19)) && gr==0
        cn = consumpNaive*sclr2[j-15]
        x = [ones(size(cn)) cn cn^2]
        consump = x⋅b2[:,j-15]
        consump /= sclr2[j-15]
    elseif any(in.(j,16:19)) && gr==1
        cn = consumpNaive*sclr3[j-15]
        x = [ones(size(cn)) cn cn^2]
        consump = x⋅b3[:,j-15]
        consump /= sclr3[j-15]
    end
    return consump[1]
end

function probgrad(Xfixed,unobtype,gbeta,abil,c2,c4)

    # there are 20 options in the non-graduate choice set
    pgrad = zeros(20)

    #  graduation probability X's
    cs    = c2+c4
    Xtemp = zeros(10,26)
    Xtemp[:,1]  .= Xfixed[1]
    Xtemp[:,2]  .= Xfixed[2]
    Xtemp[:,3]  .= Xfixed[3]
    Xtemp[:,4]  .= Xfixed[4]
    Xtemp[:,5]  .= Xfixed[5]
    Xtemp[:,6]  .= Xfixed[6]==1980
    Xtemp[:,7]  .= Xfixed[6]==1981
    Xtemp[:,8]  .= Xfixed[6]==1982
    Xtemp[:,9]  .= Xfixed[6]==1983
    Xtemp[:,10] .= Xfixed[7]
    Xtemp[:,11] .= c2==0
    Xtemp[:,12] .= c2≥2
    Xtemp[:,13] .= c4==2
    Xtemp[:,14] .= c4==3
    Xtemp[:,15] .= c4==4
    Xtemp[:,16] .= c4==5
    Xtemp[:,17] .= c4≥6
    Xtemp[:,18] .= (c2==0).*(c4==2)
    Xtemp[:,19] .= (c2==0).*(c4==4)
    Xtemp[:,20] .= (c2==0).*(c4==5)
    Xtemp[:,21] .= (c2==0).*(c4≥6)
    Xtemp[:,22]  = [ones(5);zeros(5)] # sci maj dummy
    Xtemp[:,23]  = [ones(5);zeros(5)].*abil[2]
    Xtemp[:,24]  = [zeros(5);ones(5)].*abil[3]
    Xtemp[:,25]  = [0;0;1;1;0;0;0;1;1;0]
    Xtemp[:,26]  = [1;1;0;0;0;1;1;0;0;0]
    
    # add unobserved types
    Xtemp = hcat(Xtemp,ones(10)*[(unobtype ∈ [1;2;3;4]) (unobtype ∈ [1;2;5;6]) (unobtype ∈ [1;3;5;7])])

    if cs≥2
        pgrad[6:15] = exp.(Xtemp*gbeta)./(1 .+ exp.(Xtemp*gbeta))
    end

    return pgrad
end

# this function returns the white collar offer arrival probability only as a function of individual characteristics
function pwsimple(unobtype,age,grad4yr,coefs)
    # make age gradient flat after t=19 (last period in estimation)
    if age≥19
        age = 19
    end
    X = hcat(1,age,grad4yr,[(unobtype ∈ [1;2;3;4]) (unobtype ∈ [1;2;5;6]) (unobtype ∈ [1;3;5;7])])
    #lambda = exp(X⋅coefs)/(1 + exp(X⋅coefs))
    lambda = 1
    return lambda
end

# this function returns the white collar offer arrival probability for either grads or undergrads
function pw(unobtype,age,grad4yr,coefs)
    # make age gradient flat after t=19 (last period in estimation)
    if age≥19
        age = 19
    end
    if grad4yr==1
        N = 5
        prevWC = [0;1;0;1;0]
    else
        N = 20
        prevWC = [0;1;0;1;0;0;1;0;1;0;0;1;0;1;0;0;1;0;1;0]
    end
    X = ones(N)*hcat(1,age,grad4yr,[(unobtype ∈ [1;2;3;4]) (unobtype ∈ [1;2;5;6]) (unobtype ∈ [1;3;5;7])])
    lambda = exp.(X*coefs)./(1 .+ exp.(X*coefs))
    lambda[:] .= 1
    return lambda
end

# this function returns the white collar offer arrival probability for undergrads, assuming they are grads
function pwg(unobtype,age,grad4yr,coefs)
    # make age gradient flat after t=19 (last period in estimation)
    if age≥19
        age = 19
    end
    N = 20
    prevWC = [0;1;0;1;0;0;1;0;1;0;0;1;0;1;0;0;1;0;1;0]
    X = ones(N)*hcat(1,age,grad4yr,[(unobtype ∈ [1;2;3;4]) (unobtype ∈ [1;2;5;6]) (unobtype ∈ [1;3;5;7])]) 
    lambda = exp.(X*coefs)./(1 .+ exp.(X*coefs))
    lambda[:] .= 1
    return lambda
end

function WPTupdater(X,j,sector)
    if sector=="bc"
        X[34] = any(in.(j,[3 8 13 16])) # current PT
    elseif sector=="wc"
        X[34] = any(in.(j,[4 9 14 17])) # current PT
    end
    
    return X
end

############################################### WAGES ###########################################
"""
    createWwages(Xfxx,typs,prbilstruct,ap,state)

This function computes the expected consumption given the current value of the state variables

Inputs are:
Xfxx: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
typs: unobserved type (a number between 1 & S)
prbilstruct: vector of abilities
ap: named tuple holding all parameters of simulation
state: named uple holding current value of all states

Functions the program calls:
WPTupdater: updates expected wage matrices for part-time work alternative

"""
function createWwages(Xfxx,typs,prbilstruct,ap,state)
    N = 1
    black = Xfxx[2]
    hispanic = Xfxx[3]
    HS_grades = Xfxx[4]
    Parent_college = Xfxx[5]
    birthYr = Xfxx[6]
    typpe = typs
    age   = state.age
    exper = state.exper
    exper_white_collar = state.exper_white_collar
    cum_2yr = state.cum_2yr
    cum_4yr = state.cum_4yr
    grad_4yr = state.grad_4yr
    finalMajorSci = state.finalMajorSci
    year = 0
    prior_ability_U = prbilstruct[5]
    prior_ability_S = prbilstruct[4]
    S = ap.S

    ydg = 18:33
    ydn = 18:33

    ability_range_bc = length(ap.unskilledWageBeta_a[1:end-3])+1
    ability_range_wc = length(  ap.skilledWageBeta_a[1:end-3])+1

    wageparmbc = vcat(ap.unskilledWageBetaMat[1:ability_range_bc-1,:],ones(1,size(ap.unskilledWageBetaMat,2)),ap.unskilledWageBetaMat[ability_range_bc:end,:])
    wageparmwc = vcat(  ap.skilledWageBetaMat[1:ability_range_wc-1,:],ones(1,size(  ap.skilledWageBetaMat,2)),  ap.skilledWageBetaMat[ability_range_wc:end,:])

    ## make sure that college graduates get the wages of 4+ year college completers
    ## define cum_sch here but insert it piecewise into the two different branches
    #cum_sch = (1-grad_4yr)*min(cum_2yr+cum_4yr,4) + 4*grad_4yr

    ## Get expected log wages along different finite dependence paths
    E_ln_wage = zeros(size(black,1),20)
    cum_sch   = min(cum_2yr+cum_4yr,4)
    gr4       = false
    sm        = false
    # non-grads
    for j = setdiff(1:20,[5 10 15 20]) # loop over all current decisions
        baseXbcWage = [ones(N) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age≤0 age==1 age==2 exper exper_white_collar cum_sch gr4 sm*gr4 year≤1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N)*any(in.(j,[3 8 13 16 23])) prior_ability_U [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]]
                                                                                                                                                                                    
        baseXwcWage = [ones(N) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age≤0 age==1 age==2 exper exper_white_collar cum_sch gr4 sm*gr4 year≤1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N)*any(in.(j,[4 9 14 17 24])) prior_ability_S [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]]

        lamtildg0 = 0*any(in.(j,[17 19])) + ap.lambdag0start*any(in.(j,[2 4 7 9 12 14]))
        lamtildg1 = 1*any(in.(j,[17 19])) + ap.lambdag1start*any(in.(j,[2 4 7 9 12 14]))
        lamtildn0 = 0*any(in.(j,[16 18])) + ap.lambdan0start*any(in.(j,[1 3 6 8 11 13]))
        lamtildn1 = 1*any(in.(j,[16 18])) + ap.lambdan1start*any(in.(j,[1 3 6 8 11 13]))
        if any(in.(j,[1 3 6 8 11 13 16 18])) # blue collar alternatives
            Xnew = WPTupdater(baseXbcWage,j,"bc") # argument after j is graduate dummy
            E_ln_wage[1,j] = lamtildn0 + state.ggt + lamtildn1*(Xnew[setdiff(1:size(Xnew,2),ydn)]⋅wageparmbc[setdiff(1:size(Xnew,2),ydn),1])
        elseif any(in.(j,[2 4 7 9 12 14 17 19])) # white collar alternatives
            Xnew = WPTupdater(baseXwcWage,j,"wc") # argument after j is graduate dummy
            E_ln_wage[1,j] = lamtildg0 + ap.lambdaydgstart*state.ggt + lamtildg1*(Xnew[setdiff(1:size(Xnew,2),ydg)]⋅wageparmwc[setdiff(1:size(Xnew,2),ydg),1])
        end
    end

    E_ln_wage_g = zeros(size(black,1),20)
    cum_sch     = 4
    gr4         = true
    sm          = finalMajorSci
    # grads
    for j = 16:20 # loop over all current decisions
        baseXbcWage = [ones(N) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age≤0 age==1 age==2 exper exper_white_collar cum_sch gr4 sm*gr4 year≤1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N)*any(in.(j,[3 8 13 16])) prior_ability_U [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]]

        baseXwcWage = [ones(N) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age≤0 age==1 age==2 exper exper_white_collar cum_sch gr4 sm*gr4 year≤1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N)*any(in.(j,[4 9 14 17])) prior_ability_S [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]]

        lamtildg0 = 0*any(in.(j,[17 19]))
        lamtildg1 = 1*any(in.(j,[17 19]))
        lamtildn0 = 0*any(in.(j,[16 18]))
        lamtildn1 = 1*any(in.(j,[16 18]))
        if any(in.(j,[16 18])) # blue collar alternatives
            Xnew = WPTupdater(baseXbcWage,j,"bc") # argument after j is graduate dummy
            E_ln_wage_g[1,j] = lamtildn0 + state.ggt + lamtildn1*(Xnew[setdiff(1:size(Xnew,2),ydn)]⋅wageparmbc[setdiff(1:size(Xnew,2),ydn),1])
        elseif any(in.(j,[17 19])) # white collar alternatives
            Xnew = WPTupdater(baseXwcWage,j,"wc") # argument after j is graduate dummy
            E_ln_wage_g[1,j] = lamtildg0 + ap.lambdaydgstart*state.ggt + lamtildg1*(Xnew[setdiff(1:size(Xnew,2),ydg)]⋅wageparmwc[setdiff(1:size(Xnew,2),ydg),1])
        end
    end

    ewages = (
              E_ln_wage = E_ln_wage,
              E_ln_wage_g = E_ln_wage_g
             )
    return ewages
end

############################################### EXPECTED CONSUMPTION ###########################################
"""
    e_work_c_cf(lnw,hrs,repay,Clb,θ,vabil,vnoise)

This function computes the expected consumption in the work sector (using closed form or quadrature solution of integral) given wages and hours worked as well as the wage distribution

Inputs are:
lnw: expected log wage (hourly)
hrs: total hours worked (annually)
repay: amount of loan repayment
Clb: consumption lower bound
θ: vector of abilities
vabil: prior variance of ability
vnoise: idiosyncratic wage variance
"""
function e_work_c_cf(lnw,hrs,repay,Clb,θ,vabil,vnoise)
    if repay==0
        a     = Clb^(1-θ)
        mw    = lnw+log(hrs)
        sig2w = vnoise+vabil
        mz    = (1-θ)*mw
        sig2z = (1-θ)^2 * (vnoise + vabil)
        if θ>1
            ez = exp(mz+sig2z/2)*(     cdf(Normal(), (log(a)-mz-sig2z )/sqrt(sig2z)   )/    cdf(Normal(), (log(a)-mz)/sqrt(sig2z) )   )
        elseif θ<1
            ez = exp(mz+sig2z/2)*( ( 1-cdf(Normal(), (log(a)-mz-sig2z )/sqrt(sig2z) ) )/( 1-cdf(Normal(), (log(a)-mz)/sqrt(sig2z) ) ) )
        else
            throw("θ=1 not well defined!")
        end
        Fw = cdf( Normal(mw,sqrt(sig2w)) , log(Clb) )
        ec = (1/(1-θ))*(Fw*(Clb^(1-θ)) + (1-Fw)*ez)
    else
        if θ==1
            throw("θ=1 not well defined!")
        else
            ec, err = quadgk(x -> ( (1/(1-θ))*max(exp(log(hrs)+x)-repay,Clb)^(1-θ) ) * pdf(Normal(lnw,sqrt(vabil+vnoise)),x) , -100, 100, rtol=1e-6)
        end
    end
    return ec
end

"""
    intgrt_wrk_mc(ndim,ispt,Clb,θ,tui,loan,loghrs,m1,m2,m3,s1,s2,s3,D) 

This function computes the expected consumption in the school-and-work sector (using Monte Carlo integration) given consumption inputs

Inputs are:
ndim: how many dimensions of integration
ispt: are parental transfers involved?
Clb: consumption lower bound
θ: CRRA parameter
tui: amount of tuition
loan: amount of loans
loghrs: log(hours worked)
m1: mean of variable 1 of integration
m2: mean of variable 2 of integration
m3: mean of variable 3 of integration
s1: stdev of variable 1 of integration
s2: stdev of variable 2 of integration
s3: stdev of variable 3 of integration
D: number of Monte Carlo draws
"""
function intgrt_wrk_mc(ndim,ispt,Clb,θ,tui,loan,loghrs,m1,m2,m3,s1,s2,s3,D)
    # this function computes integrals by Monte Carlo simulation
    est = 0.0
    if ndim==1
        if θ==1
            throw("θ=1 not well defined!")
        else
            est, err = quadgk(x -> ( (1/(1-θ))*max(exp(loghrs+x)+loan-tui,Clb)^(1-θ) ) * pdf(Normal(m1,s1),x) , -100, 100, rtol=1e-6)
        end
    elseif ndim==2
        if ispt
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                est+=(1/D)*max(exp(loghrs+x1)+exp(x2)+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        else
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                est+=(1/D)*max(exp(loghrs+x1)+    x2 +loan-tui,Clb)^(1-θ)/(1-θ)
            end
        end
    elseif ndim==3
        if ispt
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                x3  = rand(Normal(m3,s3))
                est+=(1/D)*max(exp(loghrs+x1)+exp(x2)+x3+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        else
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                x3  = rand(Normal(m3,s3))
                est+=(1/D)*max(exp(loghrs+x1)+    x2 +x3+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        end
    end
    return est
end

"""
    e_w_sch_c_mc(Clb,θ,xbw,hrs,xbpt,xbg,xbl,tui,sigw,sigpt,sigg,prpt,prg,D) 

This function computes the expected consumption (over parental transfers and grants) in the school-and-work sector 
given expected consumption in four different cells (no parental transfers or grants; par. trans. but no grants;
no par. trans. but grants; par. trans. and grants)

Inputs are:
Clb: consumption lower bound
θ: CRRA parameter
xbw: expected log wage
hrs: hours worked
xbpt: expected parental transfers
xbg: expected grants
xbl: expected loans
tui: amount of tuition
sigw: RMSE of log wages
sigpt: RMSE of parental transfers (conditional on being positive)
sigg: RMSE of grants (conditional on being positive) 
prpt: probability of parental transfers > 0
prg: probability of grants > 0
D: number of Monte Carlo draws
"""
function e_w_sch_c_mc(Clb,θ,xbw,hrs,xbpt,xbg,xbl,tui,sigw,sigpt,sigg,prpt,prg,D)
    c1 = (1-prpt)*(1-prg)*intgrt_wrk_mc(1,false,Clb,θ,tui,xbl,log(hrs),xbw,[],[],sigw,[],[],D)
    c2 =    prpt *(1-prg)*intgrt_wrk_mc(2,true,Clb,θ,tui,xbl,log(hrs),xbw,xbpt,[],sigw,sigpt,[],D)
    c3 = (1-prpt)*   prg *intgrt_wrk_mc(2,false,Clb,θ,tui,xbl,log(hrs),xbw,xbg,[],sigw,sigg,[],D)
    c4 =    prpt *   prg *intgrt_wrk_mc(3,true,Clb,θ,tui,xbl,log(hrs),xbw,xbpt,xbg,sigw,sigpt,sigg,D)
    ec = c1+c2+c3+c4
    return ec
end

"""
    intgrt_sch_mc(ndim,ispt,Clb,θ,tui,loan,m1,m2,s1,s2,D) 

This function computes the expected consumption in the school-only sector (using Monte Carlo integration) given consumption inputs

Inputs are:
ndim: how many dimensions of integration
ispt: are parental transfers involved?
Clb: consumption lower bound
θ: CRRA parameter
tui: amount of tuition
loan: amount of loans
m1: mean of variable 1 of integration
m2: mean of variable 2 of integration
s1: stdev of variable 1 of integration
s2: stdev of variable 2 of integration
D: number of Monte Carlo draws
"""
function intgrt_sch_mc(ndim,ispt,Clb,θ,tui,loan,m1,m2,s1,s2,D)
    # this function computes integrals by Monte Carlo simulation
    est = 0.0
    if ndim==1
        if ispt
            for d=1:D
                x1  = rand(Normal(m1,s1))
                est+=(1/D)*max(exp(x1)+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        else
            for d=1:D
                x1  = rand(Normal(m1,s1))
                est+=(1/D)*max(    x1 +loan-tui,Clb)^(1-θ)/(1-θ)
            end
        end
    elseif ndim==2
        if ispt
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                est+=(1/D)*max(exp(x1)+x2+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        else
            for d=1:D
                x1  = rand(Normal(m1,s1))
                x2  = rand(Normal(m2,s2))
                est+=(1/D)*max(    x1 +x2+loan-tui,Clb)^(1-θ)/(1-θ)
            end
        end
    end
    return est
end

"""
    e_sch_c_mc(Clb,θ,xbpt,xbg,xbl,tui,sigpt,sigg,prpt,prg,D) 

This function computes the expected consumption (over parental transfers and grants) in the school-only sector 
given expected consumption in four different cells (no parental transfers or grants; par. trans. but no grants;
no par. trans. but grants; par. trans. and grants)

Inputs are:
Clb: consumption lower bound
θ: CRRA parameter
xbpt: expected parental transfers
xbg: expected grants
xbl: expected loans
tui: amount of tuition
sigpt: RMSE of parental transfers (conditional on being positive)
sigg: RMSE of grants (conditional on being positive) 
prpt: probability of parental transfers > 0
prg: probability of grants > 0
D: number of Monte Carlo draws
"""
function e_sch_c_mc(Clb,θ,xbpt,xbg,xbl,tui,sigpt,sigg,prpt,prg,D)
    c1 = (1-prpt)*(1-prg)*max(xbl-tui,Clb)^(1-θ)/(1-θ)
    c2 =    prpt *(1-prg)*intgrt_sch_mc(1,true,Clb,θ,tui,xbl,xbpt,[],sigpt,[],D)
    c3 = (1-prpt)*   prg *intgrt_sch_mc(1,false,Clb,θ,tui,xbl,xbg,[],sigg,[],D)
    c4 =    prpt *   prg *intgrt_sch_mc(2,true,Clb,θ,tui,xbl,xbpt,xbg,sigpt,sigg,D)
    ec = c1+c2+c3+c4
    return ec
end


"""
    createconsump_naive(Xfix,fstcns,typps,prablstrct,stt,allparms)

This function computes the "naive" expected consumption given the current value of the state variables

Inputs are:
Xfix: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fstcns: dataframe holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
typps: unobserved type (a number between 1 & S)
prablstrct: vector of abilities
stt: named tuple holding current values of state variables
allparms: named tuple holding all parameters

Functions the program calls:
createWwages: calculates expected wages at the given values of the state variables
getParTransIdx: calculates the expected parental transfers (conditional on having any) given the current values of the state variables
getParTransPr: calculates the predicted probability of positive parental transfers given the current values of the state variables

"""
function createconsump_naive(Xfix,fstcns,typps,prablstrct,stt,allparms)
    Clb  = allparms.Clb
    CRRA = allparms.CRRA

    wages = createWwages(Xfix,typps,prablstrct,allparms,stt)
    E_ln_wage = wages.E_ln_wage
    E_ln_wage_g = wages.E_ln_wage_g
    grant4idx = fstcns.grant4idx
    grant2idx = fstcns.grant2idx
    loan4idx  = fstcns.E_loan4_18
    loan2idx  = fstcns.E_loan2_18
    tui4imp   = fstcns.tui4imp
    tui2imp   = fstcns.tui2imp
    rrr       = allparms.intrate
    ttt       = stt.age

    # wages in levels
    jhrs     = [repeat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0]
    jhrs_g   = [zeros(1,15) 20*52 20*52 40*52 40*52 0]
    wrkr     = ones(size(E_ln_wage  ,1))*jhrs
    wrkr_g   = ones(size(E_ln_wage_g,1))*jhrs_g
    E_wage   = wrkr.*exp.(E_ln_wage)
    E_wage_g = wrkr_g.*exp.(E_ln_wage_g)

    ## Get consumption components in conformable size (i.e. replicate to account for missing majors and unobs types)
    # PT (2- and 4-year), Grants (2- and 4-year), Loans (2- and 4-year), Tuition (2- and 4-year)

    pt4idx = getParTransIdx(Xfix,stt,fstcns,4)
    pt2idx = getParTransIdx(Xfix,stt,fstcns,2)
    gr4idx = grant4idx
    gr2idx = grant2idx
    lo4idx = loan4idx*(1+rrr)^(ttt)
    lo2idx = loan2idx*(1+rrr)^(ttt)
    tu4    = tui4imp
    tu2    = tui2imp

    consumpNaive   = fill(0.0,1,20)
    consumpNaive_g = fill(0.0,1,20)

    if stt.grad_4yr==0
        # non-grads
        for j = 1:20 # loop over all current decisions
            if ttt≤(allparms.T1-1) # don't need to compute consumption for schooling when it isn't possible to be chosen
                # school only
                if j==5
                    consumpNaive[1,5]       =         max(exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                    consumpNaive[1,[10 15]] = repeat([max(exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)],1,2)
                # 2yr and work (blue collar)
                elseif any(in.(j,[1 3]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                # 2yr and work (white collar)
                elseif any(in.(j,[2 4]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                # 4yrS and work (blue collar)
                elseif any(in.(j,[6 8]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)
                # 4yrS and work (white collar)
                elseif any(in.(j,[7 9]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)
                end
                # 4yrNS
                consumpNaive[1,11:14] .= consumpNaive[1,6:9]
            end
            # work only
            if any(in.(j,[16 18]))
                consumpNaive[1,j] = max(E_wage[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            elseif any(in.(j,[17 19]))
                consumpNaive[1,j] = max(E_wage[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            elseif j==20
                consumpNaive[1,j] = Clb^(1. - CRRA)/(1. - CRRA)
            end
        end
    elseif stt.grad_4yr==1
        # grads
        for j = 16:20 # loop over all current decisions
            # blue collar
            if any(in.(j,[16 18]))
                consumpNaive_g[1,j] = max(E_wage_g[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            # white collar
            elseif any(in.(j,[17 19]))
                consumpNaive_g[1,j] = max(E_wage_g[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            # home
            elseif any(in.(j,[20]))
                consumpNaive_g[1,j] = Clb^(1. - CRRA)/(1. - CRRA)
            end
        end
    end

    econsumps = (
                 consumpNaive = consumpNaive,
                 consumpNaive_g = consumpNaive_g
                )
    return econsumps
end

"""
    createconsump_polynomial(Xfix,fstcns,typps,prablstrct,stt,allparms)
This function computes the expected consumption given the current value of the state variables
Inputs are:
Xfix: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fstcns: dataframe holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
typps: unobserved type (a number between 1 & S)
prablstrct: vector of abilities
stt: named tuple holding current values of state variables
allparms: named tuple holding all parameters
Functions the program calls:
createWwages: calculates expected wages at the given values of the state variables
getParTransIdx: calculates the expected parental transfers (conditional on having any) given the current values of the state variables
getParTransPr: calculates the predicted probability of positive parental transfers given the current values of the state variables
"""
function createconsump_polynomial(Xfix,fstcns,typps,prablstrct,stt,allparms)
    Clb = allparms.Clb
    CRRA = allparms.CRRA

    wages = createWwages(Xfix,typps,prablstrct,allparms,stt)
    E_ln_wage = wages.E_ln_wage
    E_ln_wage_g = wages.E_ln_wage_g
    grant4idx = fstcns.grant4idx
    grant2idx = fstcns.grant2idx
    loan4idx  = fstcns.E_loan4_18
    loan2idx  = fstcns.E_loan2_18
    tui4imp   = fstcns.tui4imp
    tui2imp   = fstcns.tui2imp
    grant4pr  = fstcns.grant4pr
    grant2pr  = fstcns.grant2pr
    rrr       = allparms.intrate
    ttt       = stt.age

    # wages in levels
    jhrs     = [repeat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0]
    jhrs_g   = [zeros(1,15) 20*52 20*52 40*52 40*52 0]
    wrkr     = ones(size(E_ln_wage  ,1))*jhrs
    wrkr_g   = ones(size(E_ln_wage_g,1))*jhrs_g
    E_wage   = wrkr.*exp.(E_ln_wage)
    E_wage_g = wrkr_g.*exp.(E_ln_wage_g)

    ## Get consumption components in conformable size (i.e. replicate to account for missing majors and unobs types)
    # PT (2- and 4-year), Grants (2- and 4-year), Loans (2- and 4-year), Tuition (2- and 4-year)

    pt4idx = getParTransIdx(Xfix,stt,fstcns,4)
    pt2idx = getParTransIdx(Xfix,stt,fstcns,2)
    gr4idx = grant4idx
    gr2idx = grant2idx
    lo4idx = loan4idx*(1+rrr)^(ttt)
    lo2idx = loan2idx*(1+rrr)^(ttt)
    prpt4  = getParTransPr(Xfix,stt,fstcns,4)
    prpt2  = getParTransPr(Xfix,stt,fstcns,2)
    prg4   = grant4pr
    prg2   = grant2pr
    tu4    = tui4imp
    tu2    = tui2imp

    pt2pridx = log(prpt2/(1-prpt2))
    pt4pridx = log(prpt4/(1-prpt4))
    gr2pridx = log(prg2/(1-prg2))
    gr4pridx = log(prg4/(1-prg4))

    consump   = fill(0.0,1,20)
    consump_g = fill(0.0,1,20)

    consumpNaive   = fill(0.0,1,20)
    consumpNaive_g = fill(0.0,1,20)

    if stt.grad_4yr==0
        # non-grads
        for j = 1:20 # loop over all current decisions
            if ttt≤(allparms.T1-1) # don't need to compute consumption for schooling when it isn't possible to be chosen
                # school only
                if j==5
                    consumpNaive[1,5] = max(exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                    consumpNaive[1,[10 15]] = repeat([max(exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)],1,2)
                # 2yr and work (blue collar)
                elseif any(in.(j,[1 3]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                # 2yr and work (white collar)
                elseif any(in.(j,[2 4]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt2idx)+gr2idx+lo2idx-tu2,Clb)^(1. - CRRA)/(1. - CRRA)
                # 4yrS and work (blue collar)
                elseif any(in.(j,[6 8]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)
                # 4yrS and work (white collar)
                elseif any(in.(j,[7 9]))
                    consumpNaive[1,j] = max(E_wage[1,j]+exp(pt4idx)+gr4idx+lo4idx-tu4,Clb)^(1. - CRRA)/(1. - CRRA)
                end
                # 4yrNS
                consumpNaive[1,11:14] .= consumpNaive[1,6:9]
                consump[1,j] = predconsump(j,0,allparms.cmapParms.cmap_nograd,allparms.cmapParms.cmap_nograd_work,allparms.cmapParms.cmap_grad_work,allparms.cmapParms.scaler_nograd,allparms.cmapParms.scaler_nograd_work,allparms.cmapParms.scaler_grad_work,consumpNaive[1,j],gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,lo2idx,lo4idx)
            end
            # work only
            if any(in.(j,[16 18]))
                consumpNaive[1,j] = max(E_wage[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
                consump[1,j] = predconsump(j,0,allparms.cmapParms.cmap_nograd,allparms.cmapParms.cmap_nograd_work,allparms.cmapParms.cmap_grad_work,allparms.cmapParms.scaler_nograd,allparms.cmapParms.scaler_nograd_work,allparms.cmapParms.scaler_grad_work,consumpNaive[1,j],gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,lo2idx,lo4idx)
            elseif any(in.(j,[17 19]))
                consumpNaive[1,j] = max(E_wage[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
                consump[1,j] = predconsump(j,0,allparms.cmapParms.cmap_nograd,allparms.cmapParms.cmap_nograd_work,allparms.cmapParms.cmap_grad_work,allparms.cmapParms.scaler_nograd,allparms.cmapParms.scaler_nograd_work,allparms.cmapParms.scaler_grad_work,consumpNaive[1,j],gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,lo2idx,lo4idx)
            elseif j==20
                consumpNaive[1,j] = Clb^(1. - CRRA)/(1. - CRRA)
                consump[1,j] = predconsump(j,0,allparms.cmapParms.cmap_nograd,allparms.cmapParms.cmap_nograd_work,allparms.cmapParms.cmap_grad_work,allparms.cmapParms.scaler_nograd,allparms.cmapParms.scaler_nograd_work,allparms.cmapParms.scaler_grad_work,consumpNaive[1,j],gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,lo2idx,lo4idx)
            end
        end
    elseif stt.grad_4yr==1
        # grads
        for j = 16:20 # loop over all current decisions
            # blue collar
            if any(in.(j,[16 18]))
                consumpNaive_g[1,j] = max(E_wage_g[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            # white collar
            elseif any(in.(j,[17 19]))
                consumpNaive_g[1,j] = max(E_wage_g[1,j]-stt.repayflag*stt.loanrepay,Clb)^(1. - CRRA)/(1. - CRRA)
            # home
            elseif any(in.(j,[20]))
                consumpNaive_g[1,j] = Clb^(1. - CRRA)/(1. - CRRA)
            end
            consump_g[1,j] = predconsump(j,1,allparms.cmapParms.cmap_nograd,allparms.cmapParms.cmap_nograd_work,allparms.cmapParms.cmap_grad_work,allparms.cmapParms.scaler_nograd,allparms.cmapParms.scaler_nograd_work,allparms.cmapParms.scaler_grad_work,consumpNaive_g[1,j],gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,lo2idx,lo4idx)
        end
    end

    econsumps = (
                 consumpNaive = consumpNaive,
                 consumpNaive_g = consumpNaive_g,
                 consump = consump,
                 consump_g = consump_g
                )
    return econsumps
end


"""
    createconsump(Xfix,fstcns,typps,prablstrct,stt,allparms)

This function computes the expected consumption given the current value of the state variables

Inputs are:
Xfix: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fstcns: dataframe holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
typps: unobserved type (a number between 1 & S)
prablstrct: vector of abilities
stt: named tuple holding current values of state variables
allparms: named tuple holding all parameters

Functions the program calls:
createWwages: calculates expected wages at the given values of the state variables
getParTransIdx: calculates the expected parental transfers (conditional on having any) given the current values of the state variables
getParTransPr: calculates the predicted probability of positive parental transfers given the current values of the state variables

"""
function createconsump(Xfix,fstcns,typps,prablstrct,stt,allparms)
    Clb  = allparms.Clb
    CRRA = allparms.CRRA
    nd   = fstcns.numdraws

    wages = createWwages(Xfix,typps,prablstrct,allparms,stt)
    E_ln_wage     = wages.E_ln_wage
    E_ln_wage_g   = wages.E_ln_wage_g
    grant4idx     = fstcns.grant4idx
    grant2idx     = fstcns.grant2idx
    loan4idx      = fstcns.E_loan4_18
    loan2idx      = fstcns.E_loan2_18
    tui4imp       = fstcns.tui4imp
    tui2imp       = fstcns.tui2imp
    ParTrans4RMSE = fstcns.ParTrans4RMSE
    ParTrans2RMSE = fstcns.ParTrans2RMSE
    grant4RMSE    = fstcns.grant4RMSE
    grant2RMSE    = fstcns.grant2RMSE
    grant4pr      = fstcns.grant4pr
    grant2pr      = fstcns.grant2pr
    rrr           = allparms.intrate
    ttt           = stt.age

    # wages in levels
    jhrs     = [repeat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0]
    jhrs_g   = [zeros(1,15) 20*52 20*52 40*52 40*52 0]

    ## Get consumption components in conformable size (i.e. replicate to account for missing majors and unobs types)
    # PT (2- and 4-year), Grants (2- and 4-year), Loans (2- and 4-year), Tuition (2- and 4-year)

    sig4pt = ParTrans4RMSE
    sig2pt = ParTrans2RMSE
    sigg4  = grant4RMSE
    sigg2  = grant2RMSE
    pt4idx = getParTransIdx(Xfix,stt,fstcns,4)
    pt2idx = getParTransIdx(Xfix,stt,fstcns,2)
    gr4idx = grant4idx
    gr2idx = grant2idx
    lo4idx = loan4idx*(1+rrr)^(ttt)
    lo2idx = loan2idx*(1+rrr)^(ttt)
    prpt4  = getParTransPr(Xfix,stt,fstcns,4)
    prpt2  = getParTransPr(Xfix,stt,fstcns,2)
    prg4   = grant4pr
    prg2   = grant2pr
    tu4    = tui4imp
    tu2    = tui2imp

    consump   = fill(0.0,1,20)
    consump_g = fill(0.0,1,20)

    if stt.grad_4yr==0
        # non-grads
        for j = 1:20 # loop over all current decisions
            if ttt≤(allparms.T1-1) # don't need to compute consumption for schooling when it isn't possible to be chosen
                # school only
                if j==5
                    consump[1,5]            = e_sch_c_mc(Clb,CRRA,pt2idx,gr2idx,lo2idx,tu2,sig2pt,sigg2,prpt2,prg2,nd)
                    consump[1,[10 15]]      = repeat([e_sch_c_mc(Clb,CRRA,pt4idx,gr4idx,lo4idx,tu4,sig4pt,sigg4,prpt4,prg4,nd)],1,2) # consumption doesn't depend on major
                # 2yr and work (blue collar)
                elseif any(in.(j,[1 3]))
                    consump[1,j]      = e_w_sch_c_mc(Clb,CRRA,E_ln_wage[1,j],jhrs[j],pt2idx,gr2idx,lo2idx,tu2,sqrt(allparms.σ[4]),sig2pt,sigg2,prpt2,prg2,nd)
                # 2yr and work (white collar)
                elseif any(in.(j,[2 4]))
                    consump[1,j]      = e_w_sch_c_mc(Clb,CRRA,E_ln_wage[1,j],jhrs[j],pt2idx,gr2idx,lo2idx,tu2,sqrt(allparms.σ[2]),sig2pt,sigg2,prpt2,prg2,nd)
                # 4yrS and work (blue collar)
                elseif any(in.(j,[6 8]))
                    consump[1,j]      = e_w_sch_c_mc(Clb,CRRA,E_ln_wage[1,j],jhrs[j],pt4idx,gr4idx,lo4idx,tu4,sqrt(allparms.σ[4]),sig4pt,sigg4,prpt4,prg4,nd)
                # 4yrS and work (white collar)
                elseif any(in.(j,[7 9]))
                    consump[1,j]      = e_w_sch_c_mc(Clb,CRRA,E_ln_wage[1,j],jhrs[j],pt4idx,gr4idx,lo4idx,tu4,sqrt(allparms.σ[2]),sig4pt,sigg4,prpt4,prg4,nd)
                end
                # 4yrNS
                consump[1,11:14] .= consump[1,6:9]
            end
            # work only
            if any(in.(j,[16 18]))
                consump[1,j]      = e_work_c_cf(E_ln_wage[1,j],jhrs[j],stt.repayflag*stt.loanrepay,Clb,CRRA,0.0,allparms.σ[3])
            elseif any(in.(j,[17 19]))
                consump[1,j]      = e_work_c_cf(E_ln_wage[1,j],jhrs[j],stt.repayflag*stt.loanrepay,Clb,CRRA,0.0,allparms.σ[1]) 
            elseif j==20
                consump[1,j]      = Clb^(1. - CRRA)/(1. - CRRA) 
            end
        end
    elseif stt.grad_4yr==1
        # grads
        for j = 16:20 # loop over all current decisions
            # blue collar
            if any(in.(j,[16 18]))
                consump_g[1,j]      = e_work_c_cf(E_ln_wage_g[1,j],jhrs_g[j],stt.repayflag*stt.loanrepay,Clb,CRRA,0.0,allparms.σ[3])
            # white collar
            elseif any(in.(j,[17 19]))
                consump_g[1,j]      = e_work_c_cf(E_ln_wage_g[1,j],jhrs_g[j],stt.repayflag*stt.loanrepay,Clb,CRRA,0.0,allparms.σ[1]) 
            # home
            elseif any(in.(j,[20]))
                consump_g[1,j]      = Clb^(1. - CRRA)/(1. - CRRA)
            end
        end
    end

    econsumps = (
                 consump = consump,
                 consump_g = consump_g
                )
    return econsumps
end

############################## GRAD PROBABILITY IN FLOW UTILITIES #####################################
"""
    flowutilgprob(Xf,stp,prabstr,allp,state) 

This function computes the predicted graduation probability that goes into the flow utilities

Inputs are:
Xf: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
stp: unobserved type (a number between 1 & S)
prabstr: vector of abilities
allp: named tuple holding all parameters of the model and simulation
state: named tuple holding current values of state variables

Functions the program calls:
None

"""
function flowutilgprob(Xf,stp,prabstr,allp,state)
    logitp = (x, parmv) -> exp(x⋅parmv) / (1 + exp(x⋅parmv))
    prior_ability_4S  = prabstr[2]
    prior_ability_4NS = prabstr[3]
    N = 1
    typpe = stp
    black = Xf[2]
    hispanic = Xf[3]
    HS_grades = Xf[4]
    Parent_college = Xf[5]
    birthYr = Xf[6]
    famInc = Xf[7]
    c2 = state.cum_2yr
    c4 = state.cum_4yr

    # set up unobserved types
    stype  = [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]

    # covariates that are not alternative-specific
    X = [1.0 black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc c2==0 c2>=2 c4==2 c4==3 c4==4 c4==5 c4>=6 (c4==2).*(c2==0) (c4==4).*(c2==0) (c4==5).*(c2==0) (c4>=6).*(c2==0)];
    
    # create alternative-specific matrices
    Z = zeros(1,29,19)
    for j=6:15
        Z[1,:,j] = hcat(X, (j ∈ [6;7;8;9;10]), prior_ability_4S*(j ∈ [6;7;8;9;10]), prior_ability_4NS*(j ∈ [11;12;13;14;15]), (j ∈ [8:9 13:14]), (j ∈ [6:7 11:12]), stype)
    end

    # get predicted probabilities for each alternative
    gprobdiffs = zeros(1,19)
    if (c2+c4)>=2
        for j=6:15
            gprobdiffs[1,j] = logitp(Z[1,:,j],allp.bgrad)
        end 
    end
    
    return gprobdiffs
end

############################################### FLOW UTILITIES ###########################################
"""
    updateflows(Xf,fastC,stp,prabstr,allp,discfact,state) 

This function computes the structural flow utilities

Inputs are:
Xf: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fastC: dataframe holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
stp: unobserved type (a number between 1 & S)
prabstr: vector of abilities
allp: named tuple holding all parameters of the model and simulation
discfact: discount factor
state: named tuple holding current values of state variables

Functions the program calls:
createconsump: calculates expected consumption at the given values of the state variables

"""
function updateflows(Xf,fastC,stp,prabstr,allp,discfact,state)
    consumps = createconsump(Xf,fastC,stp,prabstr,state,allp)
    prior_ability_2   = prabstr[1]
    prior_ability_4S  = prabstr[2]
    prior_ability_4NS = prabstr[3]
    consump   = consumps.consump
    consump_g = consumps.consump_g
    N = 1
    typpe = stp
    black = Xf[2]
    hispanic = Xf[3]
    HS_grades = Xf[4]
    Parent_college = Xf[5]
    birthYr = Xf[6]
    famInc = Xf[7]
    CRRA = allp.CRRA

    ##States
    finalMajorSci = state.finalMajorSci
    prev_HS = state.prev_HS
    prev_2yr = state.prev_2yr
    prev_4yrS = state.prev_4yrS
    prev_4yrNS = state.prev_4yrNS
    prev_PT = state.prev_PT
    prev_FT = state.prev_FT
    #prev_BC = state.prev_BC
    prev_WC = state.prev_WC
    #cum_2yr = state.cum_2yr
    #cum_4yr = state.cum_4yr
    #yrs_since_school = state.yrs_since_school

    if CRRA≤0.2
        multip = 1/10000
    elseif CRRA>0.2 && CRRA≤0.4
        multip = 1/1000
    elseif CRRA>0.4 && CRRA≤0.7
        multip = 1/100
    elseif CRRA>0.7 && CRRA<1.0
        multip = 1/10
    elseif CRRA>1.0 && CRRA≤1.2
        multip = 1
    elseif CRRA>1.2 && CRRA≤1.4
        multip = 10
    elseif CRRA>1.4 && CRRA≤1.5
        multip = 100
    elseif CRRA>1.6 && CRRA≤1.8
        multip = 1000
    elseif CRRA>1.8 && CRRA≤2.0
        multip = 10000
    end

    ## Form current and future flow utilities for structural MLE
    # u_{j,t} (X components)
    demogs = [ones(N) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc]
    sdemog = size(demogs,2)
    stype  = [(typpe ∈ [1;2;3;4]) (typpe ∈ [1;2;5;6]) (typpe ∈ [1;3;5;7])]

    #ORDER - 1:sprev_HS 2:sprev_2yr 3:sprev_4yrS 4:sprev_4yrNS 5:sprev_PT 6:sprev_FT 7:sprev_WC

    sprevs = zeros(size([prev_HS prev_2yr prev_4yrS prev_4yrNS prev_PT prev_FT prev_WC]))


    #Non-grad flow utilities (last 6 before types are: grad_4yr,
    #workWC, workPT, workFT, workPT*white_collar, workFT*white_collar)
    X2ftbc   = [(1-discfact).*[demogs prior_ability_2   ] multip*(consump[:,1 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) stype]]
    X2ftwc   = [(1-discfact).*[demogs prior_ability_2   ] multip*(consump[:,2 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N) zeros(N)  ones(N) zeros(N)  ones(N) stype]]
    X2ptbc   = [(1-discfact).*[demogs prior_ability_2   ] multip*(consump[:,3 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) zeros(N) stype]]
    X2ptwc   = [(1-discfact).*[demogs prior_ability_2   ] multip*(consump[:,4 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N)  ones(N) zeros(N)  ones(N) zeros(N) stype]]
    X2nw     = [(1-discfact).*[demogs prior_ability_2   ] multip*(consump[:,5 ]-consump[:,20]) sprevs (1-discfact).*[                    zeros(N,6)                        stype]]
    X4sftbc  = [(1-discfact).*[demogs prior_ability_4S  ] multip*(consump[:,6 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) stype]]
    X4sftwc  = [(1-discfact).*[demogs prior_ability_4S  ] multip*(consump[:,7 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N) zeros(N)  ones(N) zeros(N)  ones(N) stype]]
    X4sptbc  = [(1-discfact).*[demogs prior_ability_4S  ] multip*(consump[:,8 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) zeros(N) stype]]
    X4sptwc  = [(1-discfact).*[demogs prior_ability_4S  ] multip*(consump[:,9 ]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N)  ones(N) zeros(N)  ones(N) zeros(N) stype]]
    X4snw    = [(1-discfact).*[demogs prior_ability_4S  ] multip*(consump[:,10]-consump[:,20]) sprevs (1-discfact).*[                    zeros(N,6)                        stype]]
    X4nsftbc = [(1-discfact).*[demogs prior_ability_4NS ] multip*(consump[:,11]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) stype]]
    X4nsftwc = [(1-discfact).*[demogs prior_ability_4NS ] multip*(consump[:,12]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N) zeros(N)  ones(N) zeros(N)  ones(N) stype]]
    X4nsptbc = [(1-discfact).*[demogs prior_ability_4NS ] multip*(consump[:,13]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N)  ones(N) zeros(N) zeros(N) zeros(N) stype]]
    X4nsptwc = [(1-discfact).*[demogs prior_ability_4NS ] multip*(consump[:,14]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N)  ones(N) zeros(N)  ones(N) zeros(N) stype]]
    X4nsnw   = [(1-discfact).*[demogs prior_ability_4NS ] multip*(consump[:,15]-consump[:,20]) sprevs (1-discfact).*[                    zeros(N,6)                        stype]]
    Xngwptbc = [(1-discfact).*[demogs zeros(N)   ] multip*(consump[:,16]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N) zeros(N,4) stype]]
    Xngwptwc = [(1-discfact).*[demogs zeros(N)   ] multip*(consump[:,17]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N) zeros(N,4) stype]]
    Xngwftbc = [(1-discfact).*[demogs zeros(N)   ] multip*(consump[:,18]-consump[:,20]) sprevs (1-discfact).*[zeros(N) zeros(N) zeros(N,4) stype]]
    Xngwftwc = [(1-discfact).*[demogs zeros(N)   ] multip*(consump[:,19]-consump[:,20]) sprevs (1-discfact).*[zeros(N)  ones(N) zeros(N,4) stype]]

    # Grad flow utilities
    Xgwptbc  = [(1-discfact).*[demogs zeros(N)   ] multip*(consump_g[:,16]-consump_g[:,20]) sprevs (1-discfact).*[ ones(N) zeros(N) zeros(N,4) stype]]
    Xgwptwc  = [(1-discfact).*[demogs zeros(N)   ] multip*(consump_g[:,17]-consump_g[:,20]) sprevs (1-discfact).*[ ones(N)  ones(N) zeros(N,4) stype]]
    Xgwftbc  = [(1-discfact).*[demogs zeros(N)   ] multip*(consump_g[:,18]-consump_g[:,20]) sprevs (1-discfact).*[ ones(N) zeros(N) zeros(N,4) stype]]
    Xgwftwc  = [(1-discfact).*[demogs zeros(N)   ] multip*(consump_g[:,19]-consump_g[:,20]) sprevs (1-discfact).*[ ones(N)  ones(N) zeros(N,4) stype]]

    Utils = (
    sdemog    = sdemog  ,
    X2ftbc    = X2ftbc  ,
    X2ftwc    = X2ftwc  ,
    X2ptbc    = X2ptbc  ,
    X2ptwc    = X2ptwc  ,
    X2nw      = X2nw    ,
    X4sftbc   = X4sftbc ,
    X4sftwc   = X4sftwc ,
    X4sptbc   = X4sptbc ,
    X4sptwc   = X4sptwc ,
    X4snw     = X4snw   ,
    X4nsftbc  = X4nsftbc,
    X4nsftwc  = X4nsftwc,
    X4nsptbc  = X4nsptbc,
    X4nsptwc  = X4nsptwc,
    X4nsnw    = X4nsnw  ,
    Xngwptbc  = Xngwptbc,
    Xngwptwc  = Xngwptwc,
    Xngwftbc  = Xngwftbc,
    Xngwftwc  = Xngwftwc,
    Xgwptbc   = Xgwptbc ,
    Xgwptwc   = Xgwptwc ,
    Xgwftbc   = Xgwftbc ,
    Xgwftwc   = Xgwftwc ,
    stype     = stype   ,
    sprevs    = sprevs  ,
    sage      = state.age,
    number2   = size(X2nw,2)-3,       # exclude consump, grad_4yr, whiteCollar dummy
    number4s  = size(X4snw,2)-3,      # exclude consump, grad_4yr, whiteCollar dummy
    number4ns = size(X4nsnw,2)-3,     # exclude consump, grad_4yr, whiteCollar dummy
    numberpt  = size(Xngwptbc,2)-6,   # exclude abil, consump,                    workPT/FT dummies
    numberft  = size(Xngwftbc,2)-7,   # exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    numberwc  = size(Xngwftwc,2)-7,   # exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    )
    return Utils
end

############################################### SWITCHING COSTS ###########################################
"""
    getSC(gradflag,b,state)

This function computes the structural flow utilities

Inputs are:
gradflag: 1 if graduated from 4yr college, 0 otherwise
b: vector of structural parameter estimates
state: named tuple holding current values of state variables

"""
function getSC(gradflag,b,state)
    if gradflag==1
        flowutil = zeros(5)
    else
        flowutil = zeros(20)
    end

    prev_HS    = state.prev_HS
    prev_2yr   = state.prev_2yr
    prev_4yrS  = state.prev_4yrS
    prev_4yrNS = state.prev_4yrNS
    prev_PT    = state.prev_PT
    prev_FT    = state.prev_FT
    prev_WC    = state.prev_WC

    #ORDER - 1:sprev_HS 2:sprev_2yr 3:sprev_4yrS 4:sprev_4yrNS 5:sprev_PT 6:sprev_FT 7:sprev_WC

    sprevs = [prev_HS prev_2yr prev_4yrS prev_4yrNS prev_PT prev_FT prev_WC]

    b2   = b[14:20]
    b4s  = b[39:45]
    b4ns = b[64:70]
    bwpt = b[88:94]
    bwft = b[110:116]
    bwc  = b[131:137]

    if gradflag==0
        # "utility" for 2-year college:
        vng2ftbc = sprevs⋅(b2.+bwft     )
        vng2ftwc = sprevs⋅(b2.+bwft.+bwc)
        vng2ptbc = sprevs⋅(b2.+bwpt     )
        vng2ptwc = sprevs⋅(b2.+bwpt.+bwc)
        vng2     = sprevs⋅(b2           )

        # "utility" for 4-year college: Science majors
        vng4sftbc = sprevs⋅(b4s.+bwft     )
        vng4sftwc = sprevs⋅(b4s.+bwft.+bwc)
        vng4sptbc = sprevs⋅(b4s.+bwpt     )
        vng4sptwc = sprevs⋅(b4s.+bwpt.+bwc)
        vng4s     = sprevs⋅(b4s           )

        # Non-Science majors
        vng4nsftbc = sprevs⋅(b4ns.+bwft     )
        vng4nsftwc = sprevs⋅(b4ns.+bwft.+bwc)
        vng4nsptbc = sprevs⋅(b4ns.+bwpt     )
        vng4nsptwc = sprevs⋅(b4ns.+bwpt.+bwc)
        vng4ns     = sprevs⋅(b4ns           )

        # "utility" for non-grad working
        vngwptbc = sprevs⋅(bwpt     )
        vngwptwc = sprevs⋅(bwpt.+bwc)
        vngwftbc = sprevs⋅(bwft     )
        vngwftwc = sprevs⋅(bwft.+bwc)
    else
        # "utility" for grad options
        vgwptbc = sprevs⋅(     bwpt     )
        vgwptwc = sprevs⋅(     bwpt.+bwc)
        vgwftbc = sprevs⋅(     bwft     )
        vgwftwc = sprevs⋅(     bwft.+bwc)
    end

    if gradflag==0
        flowutil[1]  = vng2ftbc[1]
        flowutil[2]  = vng2ftwc[1]
        flowutil[3]  = vng2ptbc[1]
        flowutil[4]  = vng2ptwc[1]
        flowutil[5]  = vng2[1]
        flowutil[6]  = vng4sftbc[1]
        flowutil[7]  = vng4sftwc[1]
        flowutil[8]  = vng4sptbc[1]
        flowutil[9]  = vng4sptwc[1]
        flowutil[10] = vng4s[1]
        flowutil[11] = vng4nsftbc[1]
        flowutil[12] = vng4nsftwc[1]
        flowutil[13] = vng4nsptbc[1]
        flowutil[14] = vng4nsptwc[1]
        flowutil[15] = vng4ns[1]
        flowutil[16] = vngwptbc[1]
        flowutil[17] = vngwptwc[1]
        flowutil[18] = vngwftbc[1]
        flowutil[19] = vngwftwc[1]
        #flowutil[20] = 0 # already initialized at 0 above
    elseif gradflag==1
        flowutil[1]  = vgwftbc[1]   #1 "Work FT, blue collar"
        flowutil[2]  = vgwftwc[1]   #2 "Work FT, white collar"
        flowutil[3]  = vgwptbc[1]   #3 "Work PT, blue collar"
        flowutil[4]  = vgwptwc[1]   #4 "Work PT, white collar"
        #flowutil[5] = 0            #5 "Home"
    end
    return flowutil
end

"""
    getSCGinit(prevmaj,b,state)

This function computes the structural flow utilities

Inputs are:
prevmaj: 1 if graduated from humanities, 2 if graduated from sciences
b: vector of structural parameter estimates
state: named tuple holding current values of state variables

"""
function getSCGinit(prevmaj,b,state)
    flowutil = zeros(5)

    prev_HS    = 0
    prev_2yr   = 0
    prev_4yrS  = prevmaj==2
    prev_4yrNS = prevmaj==1
    prev_PT    = state.prev_PT
    prev_FT    = state.prev_FT
    prev_WC    = state.prev_WC

    #ORDER - 1:sprev_HS 2:sprev_2yr 3:sprev_4yrS 4:sprev_4yrNS 5:sprev_PT 6:sprev_FT 7:sprev_WC

    sprevs = [prev_HS prev_2yr prev_4yrS prev_4yrNS prev_PT prev_FT prev_WC]

    bwpt = b[88:94]
    bwft = b[110:116]
    bwc  = b[131:137]

    # "utility" for grad options
    vgwptbc = sprevs⋅(     bwpt     )
    vgwptwc = sprevs⋅(     bwpt.+bwc)
    vgwftbc = sprevs⋅(     bwft     )
    vgwftwc = sprevs⋅(     bwft.+bwc)

    flowutil[1]  = vgwftbc[1]     #1 "Work FT, blue collar"
    flowutil[2]  = vgwftwc[1]     #2 "Work FT, white collar"
    flowutil[3]  = vgwptbc[1]     #3 "Work PT, blue collar"
    flowutil[4]  = vgwptwc[1]     #4 "Work PT, white collar"
    #flowutil[5] = 0 # already 0  #5 "Home"
    return flowutil
end

############################################### FLOW UTILITIES ###########################################
"""
    create_util(gradflag,Xfixed,fastconsump,typevec,prabilstruct,a,state)

This function computes the structural flow utilities

Inputs are:
gradflag: 1 if graduated from 4yr college, 0 otherwise
Xfixed: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fastconsump: dataframe holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
typevec: unobserved type (a number between 1 & S)
prabilstruct: vector of abilities
a: named tuple holding all parameters of the model
state: named tuple holding current values of state variables

Functions the program calls:
updateflows: calculates flow utility covariate matrices
flowutilgprob: calculates the graduation probability at the current states

"""
function create_util(gradflag,Xfixed,fastconsump,typevec,prabilstruct,a,state)
    b      = a.bstruc
    S      = a.S
    sdemog = a.sdemog
    τ      = state.age+1

    if gradflag==1
        flowutil = zeros(5)
    else
        flowutil = zeros(20)
    end
    utd = updateflows(Xfixed,fastconsump,typevec,prabilstruct,a,0,state)
    gpr = flowutilgprob(Xfixed,typevec,prabilstruct,a,state)

    b2flg   = 2 .+ (1:utd.number2)
    b4sflg  = 2 .+ ((1+utd.number2):(utd.number2+utd.number4s))
    b4nsflg = 2 .+ ((1+utd.number2+utd.number4s):(utd.number2+utd.number4s+utd.number4ns))
    bwptflg = 2 .+ ((1+utd.number2+utd.number4s+utd.number4ns):(utd.number2+utd.number4s+utd.number4ns+utd.numberpt))
    bwftflg = 2 .+ ((1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt):(utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft))
    bwcflg  = 2 .+ ((1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft):(utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft+utd.numberwc))

    alpha     = b[1]
    rho       = b[2]
    b2        = b[b2flg]
    b2temp    = [b2[1:sdemog+1];0;b2[sdemog+2:end-7];0;0;b2[end-6:end]] # two 0s: grad_4yr, white_collar
    b4s       = b[b4sflg]
    b4stemp   = [b4s[1:sdemog+1];0;b4s[sdemog+2:end-7];0;0;b4s[end-6:end]]
    b4ns      = b[b4nsflg]
    b4nstemp  = [b4ns[1:sdemog+1];0;b4ns[sdemog+2:end-7];0;0;b4ns[end-6:end]]
    bwpt      = b[bwptflg]
    bwpttemp  = [bwpt[1:sdemog];0;0;bwpt[sdemog+1:end-3];0;0;0;0;bwpt[end-2:end]] # only two 0s here bc need to estimate white_collar parameter
    bwft      = b[bwftflg]
    bwfttemp  = [bwft[1:sdemog];0;0;bwft[sdemog+1:end-3];0;0;0;0;0;bwft[end-2:end]]
    bwc       = b[bwcflg]
    bwctemp   = [bwc[1:sdemog];0;0;bwc[sdemog+1:end-3];0;0;0;0;0;bwc[end-2:end]]

    # indices to flag consumption and non-consumption covariates in matrices
    cidx      = sdemog+2

    if gradflag==0
        # "utility" for 2-year college:
        vng2ftbc = utd.X2ftbc*(b2temp.+bwfttemp         )+utd.X2ftbc[:,cidx]*alpha.+gpr[:,1]*rho
        vng2ftwc = utd.X2ftwc*(b2temp.+bwfttemp.+bwctemp)+utd.X2ftwc[:,cidx]*alpha.+gpr[:,2]*rho
        vng2ptbc = utd.X2ptbc*(b2temp.+bwpttemp         )+utd.X2ptbc[:,cidx]*alpha.+gpr[:,3]*rho
        vng2ptwc = utd.X2ptwc*(b2temp.+bwpttemp.+bwctemp)+utd.X2ptwc[:,cidx]*alpha.+gpr[:,4]*rho
        vng2     = utd.X2nw*(  b2temp                   )+utd.X2nw[  :,cidx]*alpha.+gpr[:,5]*rho

        # "utility" for 4-year college: Science majors
        vng4sftbc = utd.X4sftbc*(b4stemp.+bwfttemp         )+utd.X4sftbc[:,cidx]*alpha.+gpr[:,6 ]*rho
        vng4sftwc = utd.X4sftwc*(b4stemp.+bwfttemp.+bwctemp)+utd.X4sftwc[:,cidx]*alpha.+gpr[:,7 ]*rho
        vng4sptbc = utd.X4sptbc*(b4stemp.+bwpttemp         )+utd.X4sptbc[:,cidx]*alpha.+gpr[:,8 ]*rho
        vng4sptwc = utd.X4sptwc*(b4stemp.+bwpttemp.+bwctemp)+utd.X4sptwc[:,cidx]*alpha.+gpr[:,9 ]*rho
        vng4s     = utd.X4snw*(  b4stemp                   )+utd.X4snw[  :,cidx]*alpha.+gpr[:,10]*rho

        # Non-Science majors
        vng4nsftbc = utd.X4nsftbc*(b4nstemp.+bwfttemp         )+utd.X4nsftbc[:,cidx]*alpha.+gpr[:,11]*rho
        vng4nsftwc = utd.X4nsftwc*(b4nstemp.+bwfttemp.+bwctemp)+utd.X4nsftwc[:,cidx]*alpha.+gpr[:,12]*rho
        vng4nsptbc = utd.X4nsptbc*(b4nstemp.+bwpttemp         )+utd.X4nsptbc[:,cidx]*alpha.+gpr[:,13]*rho
        vng4nsptwc = utd.X4nsptwc*(b4nstemp.+bwpttemp.+bwctemp)+utd.X4nsptwc[:,cidx]*alpha.+gpr[:,14]*rho
        vng4ns     = utd.X4nsnw*(  b4nstemp                   )+utd.X4nsnw[  :,cidx]*alpha.+gpr[:,15]*rho

        # "utility" for non-grad working
        vngwptbc = utd.Xngwptbc*(bwpttemp         ).+utd.Xngwptbc[:,cidx]*alpha.+gpr[:,16]*rho
        vngwptwc = utd.Xngwptwc*(bwpttemp.+bwctemp).+utd.Xngwptwc[:,cidx]*alpha.+gpr[:,17]*rho
        vngwftbc = utd.Xngwftbc*(bwfttemp         ).+utd.Xngwftbc[:,cidx]*alpha.+gpr[:,18]*rho
        vngwftwc = utd.Xngwftwc*(bwfttemp.+bwctemp).+utd.Xngwftwc[:,cidx]*alpha.+gpr[:,19]*rho
    else
        vgwptbc = utd.Xgwptbc*( bwpttemp                  ).+utd.Xgwptbc[ :,cidx]*alpha.+0*rho
        vgwptwc = utd.Xgwptwc*( bwpttemp.+bwctemp         ).+utd.Xgwptwc[ :,cidx]*alpha.+0*rho
        vgwftbc = utd.Xgwftbc*( bwfttemp                  ).+utd.Xgwftbc[ :,cidx]*alpha.+0*rho
        vgwftwc = utd.Xgwftwc*( bwfttemp.+bwctemp         ).+utd.Xgwftwc[ :,cidx]*alpha.+0*rho
    end

    if gradflag==0 && τ≤(a.T1)
        flowutil[1]  = vng2ftbc[1]
        flowutil[2]  = vng2ftwc[1]
        flowutil[3]  = vng2ptbc[1]
        flowutil[4]  = vng2ptwc[1]
        flowutil[5]  = vng2[1]
        flowutil[6]  = vng4sftbc[1]
        flowutil[7]  = vng4sftwc[1]
        flowutil[8]  = vng4sptbc[1]
        flowutil[9]  = vng4sptwc[1]
        flowutil[10] = vng4s[1]
        flowutil[11] = vng4nsftbc[1]
        flowutil[12] = vng4nsftwc[1]
        flowutil[13] = vng4nsptbc[1]
        flowutil[14] = vng4nsptwc[1]
        flowutil[15] = vng4ns[1]
        flowutil[16] = vngwptbc[1]
        flowutil[17] = vngwptwc[1]
        flowutil[18] = vngwftbc[1]
        flowutil[19] = vngwftwc[1]
        flowutil[20] = 0
    elseif gradflag==0 && τ>(a.T1)
        flowutil[1]  = 0
        flowutil[2]  = 0
        flowutil[3]  = 0
        flowutil[4]  = 0
        flowutil[5]  = 0
        flowutil[6]  = 0
        flowutil[7]  = 0
        flowutil[8]  = 0
        flowutil[9]  = 0
        flowutil[10] = 0
        flowutil[11] = 0
        flowutil[12] = 0
        flowutil[13] = 0
        flowutil[14] = 0
        flowutil[15] = 0
        flowutil[16] = vngwptbc[1]
        flowutil[17] = vngwptwc[1]
        flowutil[18] = vngwftbc[1]
        flowutil[19] = vngwftwc[1]
        flowutil[20] = 0
    elseif gradflag==1
        flowutil[1]  = vgwftbc[1]  #1  "Work FT, blue collar"
        flowutil[2]  = vgwftwc[1]  #2  "Work FT, white collar"
        flowutil[3]  = vgwptbc[1]  #3  "Work PT, blue collar"
        flowutil[4]  = vgwptwc[1]  #4  "Work PT, white collar"
        flowutil[5]  = 0           #5  "Home"
    end
    return flowutil
end

"""
    get_v_g(u,uSC,λ,Vw,Vb,stte,a)

This function computes the choice-specific value function given future values, flow utilities, and state transitions for college graduates

Inputs are:
u: flow utility vector
uSC: switching cost vector
λ: white collar offer arrival probability in t+1
Vw: V_{t+1} conditional on receiving a white-collar offer in t+1
Vb: V_{t+1} conditional on not receiving a white-collar offer in t+1
stte: named tuple holding all current states
a: named tuple holding all parameters

Order of choices for those who have graduated:
1 Work FT; blue collar
2 Work FT; white collar
3 Work PT; blue collar
4 Work PT; white collar
5 Home

"""
function get_v_g(u,uSC,λ,Vw,Vb,stte,a)
    Π      = a.pimb
    captot = a.CapTot
    caps   = a.CapS
    capu   = a.CapU
    exps   = convert(Int64,stte.exper_white_collar*2)
    expu   = convert(Int64,stte.exper*2 - exps)
    major  = stte.finalMajorSci==true ? 2 : 1
    cum4   = convert(Int64,stte.cum_4yr)
    cum2   = convert(Int64,stte.cum_2yr)
    grid   = convert(Int64,stte.gggrid)

    capu2 = min(captot-exps,capu)
    caps2 = min(captot-expu,caps)
    vt = zeros(5)
    vt[1] = u[1]+uSC[1]+Π[grid,:]⋅(   λ[1] *Vw[:,min(expu+3,capu2+1),exps+1             ,1,major,cum4+1,cum2+1])+
                        Π[grid,:]⋅((1-λ[1])*Vb[:,min(expu+3,capu2+1),exps+1             ,1,major,cum4+1,cum2+1])
    vt[2] = u[2]+uSC[2]+Π[grid,:]⋅(   λ[2]* Vw[:,expu+1             ,min(exps+3,caps2+1),2,major,cum4+1,cum2+1])+
                        Π[grid,:]⋅((1-λ[2])*Vb[:,expu+1             ,min(exps+3,caps2+1),2,major,cum4+1,cum2+1])
    vt[3] = u[3]+uSC[3]+Π[grid,:]⋅(   λ[3] *Vw[:,min(expu+2,capu2+1),exps+1             ,3,major,cum4+1,cum2+1])+
                        Π[grid,:]⋅((1-λ[3])*Vb[:,min(expu+2,capu2+1),exps+1             ,3,major,cum4+1,cum2+1])
    vt[4] = u[4]+uSC[4]+Π[grid,:]⋅(   λ[4] *Vw[:,expu+1             ,min(exps+2,caps2+1),4,major,cum4+1,cum2+1])+
                        Π[grid,:]⋅((1-λ[4])*Vb[:,expu+1             ,min(exps+2,caps2+1),4,major,cum4+1,cum2+1])
    vt[5] = u[5]+uSC[5]+Π[grid,:]⋅(   λ[5] *Vw[:,expu+1             ,exps+1             ,5,major,cum4+1,cum2+1])+
                        Π[grid,:]⋅((1-λ[5])*Vb[:,expu+1             ,exps+1             ,5,major,cum4+1,cum2+1])
    return vt
end



"""
    get_P_g(Pw,Pb,stte)

This function returns the choice probabilities at the appropriate states

Inputs are:
Pw: P_{t} conditional on receiving a white-collar offer in t
Pb: P_{t} conditional on not receiving a white-collar offer in t
stte: named tuple holding all current states

Order of choices for those who have graduated:
1 Work FT; blue collar
2 Work FT; white collar
3 Work PT; blue collar
4 Work PT; white collar
5 Home

"""
function get_P_g(Pw,Pb,stte)
    # get vector indices from states
    τ     = convert(Int64,stte.age+1)
    exps  = convert(Int64,stte.exper_white_collar*2)
    expu  = convert(Int64,stte.exper*2 - exps)
    major = stte.finalMajorSci==true ? 2 : 1
    cum4  = convert(Int64,stte.cum_4yr)
    cum2  = convert(Int64,stte.cum_2yr)
    grid  = convert(Int64,stte.gggrid)
    if stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==false
        lchoice = 5 # home
    elseif stte.prev_PT==true && stte.prev_WC==false && stte.prev_FT==false 
        lchoice = 3 # PT BC
    elseif stte.prev_PT==true && stte.prev_WC==true && stte.prev_FT==false 
        lchoice = 4 # PT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==true 
        lchoice = 1 # FT BC
    elseif stte.prev_PT==false && stte.prev_WC==true && stte.prev_FT==true 
        lchoice = 2 # FT WC
    else
        throw("error in lagged choice")
    end

    # order of indices: choice alt, LM shock grid, time period, BC exper, WC exper, prev. choice, major, 4yr exper, 2yr exper
    pw = Pw[:,grid,τ,expu+1,exps+1,lchoice,major,cum4+1,cum2+1]
    pb = Pb[:,grid,τ,expu+1,exps+1,lchoice,major,cum4+1,cum2+1]
    return pw, pb
end


"""
    get_v_ug(u,uSC,λ,λg,ρ,Vw,Vb,VGwi,VGbi,stte,a)

This function computes the choice-specific value function given future values, flow utilities, and state transitions for non-graduates

Inputs are:
u: flow utility vector
uSC: switching cost vector
λ: white collar offer arrival probability in τ+1
λg: white collar offer arrival probability conditional on being a graduate in τ+1
ρ: probability of graduating 4yr college next period
Vw: V_{τ+1} conditional on receiving a white-collar offer in t
Vb: V_{τ+1} conditional on not receiving a white-collar offer in t
VGwi: V_{τ+1} conditional on receiving a white-collar offer and being a graduate in τ+1
VGbi: V_{τ+1} conditional on not receiving a white-collar offer and being a graduate in τ+1
stte: named tuple holding all current states
a: named tuple holding all parameters

Order of choices for those who haven't graduated:
1  2yr & FT; blue collar
2  2yr & FT; white collar
3  2yr & PT; blue collar
4  2yr & PT; white collar
5  2yr & No Work
6  4yr Science & FT; blue collar
7  4yr Science & FT; white collar
8  4yr Science & PT; blue collar
9  4yr Science & PT; white collar
10 4yr Science & No Work
11 4yr Humanities & FT; blue collar
12 4yr Humanities & FT; white collar
13 4yr Humanities & PT; blue collar
14 4yr Humanities & PT; white collar
15 4yr Humanities & No Work
16 Work PT; blue collar
17 Work PT; white collar
18 Work FT; blue collar
19 Work FT; white collar
20 Home


"""
function get_v_ug(u,uSC,λ,λg,ρ,Vw,Vb,VGwi,VGbi,stte,a)
    Π       = a.pimb
    captot  = a.CapTot
    capctot = a.CapCTot
    caps    = a.CapSug
    capu    = a.CapU
    cap4    = a.Cap4
    cap2    = a.Cap2
    T11     = a.T1
    τ       = convert(Int64,stte.age+1)
    exps    = convert(Int64,stte.exper_white_collar*2)
    expu    = convert(Int64,stte.exper*2-exps)
    cum4    = convert(Int64,stte.cum_4yr)
    cum2    = convert(Int64,stte.cum_2yr)
    grid    = convert(Int64,stte.gggrid)

    capu2 = min(captot-exps,capu)
    caps2 = min(captot-expu,caps)
    cap42 = min(capctot-cum2,cap4)
    cap22 = min(capctot-cum4,cap2)
    vt = zeros(20)
    if τ≤T11
        # 2-year options: not at risk of graduating
        vt[1] =u[1] +uSC[1] +Π[grid,:]⋅(   λ[1]  *Vw[:,min(expu+3,capu2+1),exps+1             ,1 ,cum4+1,min(cum2+2,cap22+1)])+
                             Π[grid,:]⋅((1-λ[1] )*Vb[:,min(expu+3,capu2+1),exps+1             ,1 ,cum4+1,min(cum2+2,cap22+1)])
        vt[2] =u[2] +uSC[2] +Π[grid,:]⋅(   λ[2]  *Vw[:,expu+1             ,min(exps+3,caps2+1),2 ,cum4+1,min(cum2+2,cap22+1)])+
                             Π[grid,:]⋅((1-λ[2] )*Vb[:,expu+1             ,min(exps+3,caps2+1),2 ,cum4+1,min(cum2+2,cap22+1)])
        vt[3] =u[3] +uSC[3] +Π[grid,:]⋅(   λ[3]  *Vw[:,min(expu+2,capu2+1),exps+1             ,3 ,cum4+1,min(cum2+2,cap22+1)])+
                             Π[grid,:]⋅((1-λ[3] )*Vb[:,min(expu+2,capu2+1),exps+1             ,3 ,cum4+1,min(cum2+2,cap22+1)])
        vt[4] =u[4] +uSC[4] +Π[grid,:]⋅(   λ[4]  *Vw[:,expu+1             ,min(exps+2,caps2+1),4 ,cum4+1,min(cum2+2,cap22+1)])+
                             Π[grid,:]⋅((1-λ[4] )*Vb[:,expu+1             ,min(exps+2,caps2+1),4 ,cum4+1,min(cum2+2,cap22+1)])
        vt[5] =u[5] +uSC[5] +Π[grid,:]⋅(   λ[5]  *Vw[:,expu+1             ,exps+1             ,5 ,cum4+1,min(cum2+2,cap22+1)])+
                             Π[grid,:]⋅((1-λ[5] )*Vb[:,expu+1             ,exps+1             ,5 ,cum4+1,min(cum2+2,cap22+1)])

        # 4-year options: need to link in FV of graduating weighted by probability of graduating
        vt[6] =u[6] +uSC[6] +(1-ρ[6] )*( # non-grad branch
                                        Π[grid,:]⋅(   λ[6]  *Vw[:,min(expu+3,capu2+1),exps+1,6 ,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[6] )*Vb[:,min(expu+3,capu2+1),exps+1,6 ,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[6]  *( # grad branch
                                        Π[grid,:]⋅(   λg[6]  *VGwi[:,τ+1,min(expu+3,capu2+1),exps+1,1,2,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[6] )*VGbi[:,τ+1,min(expu+3,capu2+1),exps+1,1,2,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[7] =u[7] +uSC[7] +(1-ρ[7] )*( # non-grad branch
                                        Π[grid,:]⋅(   λ[7]  *Vw[:,expu+1,min(exps+3,caps2+1),7 ,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[7] )*Vb[:,expu+1,min(exps+3,caps2+1),7 ,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[7]  *( # grad branch
                                        Π[grid,:]⋅(   λg[7]  *VGwi[:,τ+1,expu+1,min(exps+3,caps2+1),2,2,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[7] )*VGbi[:,τ+1,expu+1,min(exps+3,caps2+1),2,2,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[8] =u[8] +uSC[8] +(1-ρ[8] )*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[8]  *Vw[:,min(expu+2,capu2+1),exps+1,8 ,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[8] )*Vb[:,min(expu+2,capu2+1),exps+1,8 ,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[8]  *( # grad branch 
                                        Π[grid,:]⋅(   λg[8]  *VGwi[:,τ+1,min(expu+2,capu2+1),exps+1,3,2,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[8] )*VGbi[:,τ+1,min(expu+2,capu2+1),exps+1,3,2,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[9] =u[9] +uSC[9] +(1-ρ[9] )*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[9]  *Vw[:,expu+1,min(exps+2,caps2+1),9 ,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[9] )*Vb[:,expu+1,min(exps+2,caps2+1),9 ,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[9]  *( # grad branch 
                                        Π[grid,:]⋅(   λg[9]  *VGwi[:,τ+1,expu+1,min(exps+2,caps2+1),4,2,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[9] )*VGbi[:,τ+1,expu+1,min(exps+2,caps2+1),4,2,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[10]=u[10]+uSC[10]+(1-ρ[10])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[10] *Vw[:,expu+1,exps+1,10,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[10])*Vb[:,expu+1,exps+1,10,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[10] *( # grad branch 
                                        Π[grid,:]⋅(   λg[10] *VGwi[:,τ+1,expu+1,exps+1,5,2,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[10])*VGbi[:,τ+1,expu+1,exps+1,5,2,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[11]=u[11]+uSC[11]+(1-ρ[11])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[11] *Vw[:,min(expu+3,capu2+1),exps+1,11,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[11])*Vb[:,min(expu+3,capu2+1),exps+1,11,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[11] *( # grad branch 
                                        Π[grid,:]⋅(   λg[11] *VGwi[:,τ+1,min(expu+3,capu2+1),exps+1,1,1,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[11])*VGbi[:,τ+1,min(expu+3,capu2+1),exps+1,1,1,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[12]=u[12]+uSC[12]+(1-ρ[12])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[12] *Vw[:,expu+1,min(exps+3,caps2+1),12,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[12])*Vb[:,expu+1,min(exps+3,caps2+1),12,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[12] *( # grad branch 
                                        Π[grid,:]⋅(   λg[12] *VGwi[:,τ+1,expu+1,min(exps+3,caps2+1),2,1,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[12])*VGbi[:,τ+1,expu+1,min(exps+3,caps2+1),2,1,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[13]=u[13]+uSC[13]+(1-ρ[13])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[13] *Vw[:,min(expu+2,capu2+1),exps+1,13,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[13])*Vb[:,min(expu+2,capu2+1),exps+1,13,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[13] *( # grad branch 
                                        Π[grid,:]⋅(   λg[13] *VGwi[:,τ+1,min(expu+2,capu2+1),exps+1,3,1,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[13])*VGbi[:,τ+1,min(expu+2,capu2+1),exps+1,3,1,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[14]=u[14]+uSC[14]+(1-ρ[14])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[14] *Vw[:,expu+1,min(exps+2,caps2+1),14,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[14])*Vb[:,expu+1,min(exps+2,caps2+1),14,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[14] *( # grad branch 
                                        Π[grid,:]⋅(   λg[14] *VGwi[:,τ+1,expu+1,min(exps+2,caps2+1),4,1,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[14])*VGbi[:,τ+1,expu+1,min(exps+2,caps2+1),4,1,min(cum4+2,cap42+1),cum2+1])
                                       )
        vt[15]=u[15]+uSC[15]+(1-ρ[15])*( # non-grad branch 
                                        Π[grid,:]⋅(   λ[15] *Vw[:,expu+1,exps+1,15,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λ[15])*Vb[:,expu+1,exps+1,15,min(cum4+2,cap42+1),cum2+1])
                                       )+
                                ρ[15] *( # grad branch 
                                        Π[grid,:]⋅(   λg[15] *VGwi[:,τ+1,expu+1,exps+1,5,1,min(cum4+2,cap42+1),cum2+1])+
                                        Π[grid,:]⋅((1-λg[15])*VGbi[:,τ+1,expu+1,exps+1,5,1,min(cum4+2,cap42+1),cum2+1])
                                       )
    end
    # non-schooling options: not at risk of graduating
    vt[16]=u[16]+uSC[16]+Π[grid,:]⋅(   λ[16] *Vw[:,min(expu+2,capu2+1),exps+1             ,16,cum4+1,cum2+1])+
                         Π[grid,:]⋅((1-λ[16])*Vb[:,min(expu+2,capu2+1),exps+1             ,16,cum4+1,cum2+1])
    vt[17]=u[17]+uSC[17]+Π[grid,:]⋅(   λ[17] *Vw[:,expu+1             ,min(exps+2,caps2+1),17,cum4+1,cum2+1])+
                         Π[grid,:]⋅((1-λ[17])*Vb[:,expu+1             ,min(exps+2,caps2+1),17,cum4+1,cum2+1])
    vt[18]=u[18]+uSC[18]+Π[grid,:]⋅(   λ[18] *Vw[:,min(expu+3,capu2+1),exps+1             ,18,cum4+1,cum2+1])+
                         Π[grid,:]⋅((1-λ[18])*Vb[:,min(expu+3,capu2+1),exps+1             ,18,cum4+1,cum2+1])
    vt[19]=u[19]+uSC[19]+Π[grid,:]⋅(   λ[19] *Vw[:,expu+1             ,min(exps+3,caps2+1),19,cum4+1,cum2+1])+
                         Π[grid,:]⋅((1-λ[19])*Vb[:,expu+1             ,min(exps+3,caps2+1),19,cum4+1,cum2+1])
    vt[20]=u[20]+uSC[20]+Π[grid,:]⋅(   λ[20] *Vw[:,expu+1             ,exps+1             ,20,cum4+1,cum2+1])+
                         Π[grid,:]⋅((1-λ[20])*Vb[:,expu+1             ,exps+1             ,20,cum4+1,cum2+1])
    return vt
end


"""
    get_P_ug(Pw,Pb,stte,a)

This function computes the choice-specific value function given future values, flow utilities, and state transitions for non-graduates

Inputs are:
Pw: P_{t} conditional on receiving a white-collar offer in t
Pb: P_{t} conditional on not receiving a white-collar offer in t
stte: named tuple holding all current states
a: named tuple holding all parameters

Order of choices for those who haven't graduated:
1  2yr & FT; blue collar
2  2yr & FT; white collar
3  2yr & PT; blue collar
4  2yr & PT; white collar
5  2yr & No Work
6  4yr Science & FT; blue collar
7  4yr Science & FT; white collar
8  4yr Science & PT; blue collar
9  4yr Science & PT; white collar
10 4yr Science & No Work
11 4yr Humanities & FT; blue collar
12 4yr Humanities & FT; white collar
13 4yr Humanities & PT; blue collar
14 4yr Humanities & PT; white collar
15 4yr Humanities & No Work
16 Work PT; blue collar
17 Work PT; white collar
18 Work FT; blue collar
19 Work FT; white collar
20 Home


"""
function get_P_ug(Pw,Pb,stte)
    # get vector indices from states
    τ    = convert(Int64,stte.age+1)
    exps = convert(Int64,stte.exper_white_collar*2)
    expu = convert(Int64,stte.exper*2-exps)
    cum4 = convert(Int64,stte.cum_4yr)
    cum2 = convert(Int64,stte.cum_2yr)
    grid = convert(Int64,stte.gggrid)
    if stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==true  && stte.prev_2yr==true && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 1 # 2yr FT BC
    elseif stte.prev_PT==false && stte.prev_WC==true && stte.prev_FT==true  && stte.prev_2yr==true && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 2 # 2yr FT WC
    elseif stte.prev_PT==true && stte.prev_WC==false && stte.prev_FT==false  && stte.prev_2yr==true && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 3 # 2yr PT BC
    elseif stte.prev_PT==true && stte.prev_WC==true && stte.prev_FT==false  && stte.prev_2yr==true && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 4 # 2yr PT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==false && stte.prev_2yr==true && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 5 # 2yr
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==true && stte.prev_4yrNS==false 
        lchoice = 6 # 4yr Sci FT BC
    elseif stte.prev_PT==false && stte.prev_WC==true && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==true && stte.prev_4yrNS==false
        lchoice = 7 # 4yr Sci FT WC
    elseif stte.prev_PT==true && stte.prev_WC==false && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==true && stte.prev_4yrNS==false 
        lchoice = 8 # 4yr Sci PT BC
    elseif stte.prev_PT==true && stte.prev_WC==true && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==true && stte.prev_4yrNS==false
        lchoice = 9 # 4yr Sci PT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==false && stte.prev_2yr==false && stte.prev_4yrS==true && stte.prev_4yrNS==false
        lchoice = 10 # 4yr Sci
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==true 
        lchoice = 11 # 4yr Hum FT BC
    elseif stte.prev_PT==false && stte.prev_WC==true && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==true
        lchoice = 12 # 4yr Hum FT WC
    elseif stte.prev_PT==true && stte.prev_WC==false && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==true 
        lchoice = 13 # 4yr Hum PT BC
    elseif stte.prev_PT==true && stte.prev_WC==true && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==true
        lchoice = 14 # 4yr Hum PT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==false && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==true
        lchoice = 15 # 4yr Hum
    elseif stte.prev_PT==true && stte.prev_WC==false && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 16 # PT BC
    elseif stte.prev_PT==true && stte.prev_WC==true && stte.prev_FT==false  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==false 
        lchoice = 17 # PT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 18 # FT BC
    elseif stte.prev_PT==false && stte.prev_WC==true && stte.prev_FT==true  && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==false 
        lchoice = 19 # FT WC
    elseif stte.prev_PT==false && stte.prev_WC==false && stte.prev_FT==false && stte.prev_2yr==false && stte.prev_4yrS==false && stte.prev_4yrNS==false
        lchoice = 20 # home
    else
        throw("error in lagged choice")
    end

    # order of indices: choice alt, LM shock grid, time period, BC exper, WC exper, prev. choice, 4yr exper, 2yr exper
    pw = Pw[:,grid,τ,expu+1,exps+1,lchoice,cum4+1,cum2+1] 
    pb = Pb[:,grid,τ,expu+1,exps+1,lchoice,cum4+1,cum2+1] 
    return pw, pb
end

"""
    get_fv_g(vt,bcf,δ)

This function computes the expected period-t+1 future value and period-t choice probability given period-t choice-specific value functions and discount factor δ

Inputs are:
vt: period-t choice-specific value function vector
bcf: flag for options which are available regardless of white collar offer arrival
δ: discount factor

"""
function get_fv_g(vt,bcf,δ)
    # update FV
    dwc = sum(exp.(vt         ))
    dbc = sum(exp.(vt[bcf.==1]))
    pwc = exp.(vt         )./dwc
    pbc = exp.(vt[bcf.==1])./dbc
    fwc = δ*log(dwc)
    fbc = δ*log(dbc)
    return fwc,fbc,pwc,pbc
end

"""
    get_fv_ug(vt,bcf,bcfT1,wcfT1,δ,τ,T11)

This function computes the expected period-τ+1 future value and period-τ choice probability given period-τ choice-specific value functions and discount factor δ

Inputs are:
vt: period-τ choice-specific value function vector
bcf: flag for options which are available regardless of white collar offer arrival
bcfT1: flag for options which are available after period T11 regardless of white collar offer arrival
wcfT1: flag for options which are available after period T11 condtional on receiving a white collar offer
δ: discount factor
τ: current time period
T11: time period after which school is not an option

"""
function get_fv_ug(vt,bcf,bcfT1,wcfT1,δ,τ,T11)
    # update FV
    if τ≤T11
        dwc = sum(exp.(vt         ))
        dbc = sum(exp.(vt[bcf.==1]))
        pwc = exp.(vt         )./dwc
        pbc = exp.(vt[bcf.==1])./dbc
    end
    if τ>T11
        dwc = sum(exp.(vt[wcfT1.==1]))
        dbc = sum(exp.(vt[bcfT1.==1]))
        pwc = exp.(vt[wcfT1.==1])./dwc
        pbc = exp.(vt[bcfT1.==1])./dbc
    end
    fwc = δ*log(dwc)
    fbc = δ*log(dbc)
    return fwc,fbc,pwc,pbc
end

"""
    fvgrad(stype,sdemog,Xfixed,fastconsump,abilvec,allparams,endperiod)

This function computes the future value terms for the graduate choice set

Inputs are:
stype: unobserved type (a number between 1 & S)
sdemog: number of demographic variables
Xfixed: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fastconsump: structure holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
abilvec: vector of abilities
allparams: named tuple holding all parameter values
endperiod: period in which the program terminates and returns the current future value array (used for testing; default value is 1)

Functions the program calls:
pw: calculates white collar offer arrival probabilities
amorization: calculates loan repayment amounts
create_util: computes flow utilities

Lagged Choice matrix based on the following order of choices for those who have graduated
1 Work FT; blue collar
2 Work FT; white collar
3 Work PT; blue collar
4 Work PT; white collar
5 Home

"""
function fvgrad(stype,Xfixed,fastconsump,abilvec,a,endperiod=0)
    # unpack the parameter named tuple
    numgrid    = a.numgrid
    T          = a.T
    T1         = a.T1
    TR         = a.TR
    CapU       = a.CapU
    CapS       = a.CapS
    CapTot     = a.CapTot
    Cap4       = a.Cap4
    Cap2       = a.Cap2
    CapCTot    = a.CapCTot
    pimb       = a.pimb
    pistb      = a.pistb
    β          = a.β
    S          = a.S
    strucb     = a.bstruc
    lamcoef    = a.boffer
    debthoriz  = a.debthorizon

    # initialize objects that will be used in the backwards recursion
    v=zeros(5)
    bc=[1;0;1;0;1]   #choices that are available with no white collar offer

    FVGinitw=zeros(numgrid,T1+1,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1) # 5 index is: workFT BC, workFT WC, workPT BC, work PT WC, no work
    FVGinitb=zeros(numgrid,T1+1,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1) # 5 index is: workFT BC, workFT WC, workPT BC, work PT WC, no work

    PChoiceGinitw=zeros(5,numgrid,T1,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1) # first 5 is number of graduate choice set options; 5 index is: workFT BC, workFT WC, workPT BC, work PT WC, no work
    PChoiceGinitb=zeros(5,numgrid,T1,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1) # first 5 is number of graduate choice set options; 5 index is: workFT BC, workFT WC, workPT BC, work PT WC, no work

    Uhold = zeros(4,numgrid,CapU+1,CapS+1,2,Cap4+1,Cap2+1)  # 4 is J-1, 2 is STEM/non-STEM
    UholdR= zeros(4,numgrid,CapU+1,CapS+1,2,Cap4+1,Cap2+1)  # 4 is J-1, 2 is STEM/non-STEM
    FVGw  = zeros(numgrid,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1)
    FVGb  = zeros(numgrid,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1)
    FV0Gw = zeros(numgrid,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1)
    FV0Gb = zeros(numgrid,CapU+1,CapS+1,5,2,Cap4+1,Cap2+1)

    PChoiceGw=zeros(5,numgrid,T1,min(2*T1+1,CapU+1),min(2*T1+1,CapS+1),5,2,Cap4+1,Cap2+1) # first 5 is J, 10 is T, second 5 is previous choice
    PChoiceGb=zeros(5,numgrid,T1,min(2*T1+1,CapU+1),min(2*T1+1,CapS+1),5,2,Cap4+1,Cap2+1) # first 5 is J, 10 is T, second 5 is previous choice
    #println("mem use (GB) in fvgrad after creating state matrices")
    #@show get_mem_use()
    #@show summarysize_mb(FVGinitw)
    #@show summarysize_mb(FVGinitb)
    #@show summarysize_gb(FVGw)
    #@show summarysize_gb(FVGb)
    #@show summarysize_gb(FV0Gw)
    #@show summarysize_gb(FV0Gb)
    #@show summarysize_gb(Uhold)
    #@show summarysize_mb(PChoiceGinitw)
    #@show summarysize_mb(PChoiceGinitb)
    #@show summarysize_gb(PChoiceGw)
    #@show summarysize_gb(PChoiceGb)
    #return PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,FVGinitw,FVGinitb

    state = ( # named tuple
             exper              = 0.0,
             exper_white_collar = 0.0,
             finalMajorSci      = false,
             prev_HS            = false,
             prev_2yr           = false,
             prev_4yrS          = false,
             prev_4yrNS         = false,
             prev_PT            = false,
             prev_FT            = false,
             prev_WC            = false,
             cum_2yr            = 0,
             cum_4yr            = 0,
             age                = 0,
             ggt                = 0.0,
             gggrid             = 1,
             grad_4yr           = true,
             loanrepay          = 0.0,
             repayflag          = false
            )

    #NOTE THAT MAJ=1 is HUM & MAJ=2 is STEM

    #For those who have graduated; the order of choices is
    #1-FT BC; 2-FT WC; 3-PT BC; 4-PT WC; 5-Home

    thrd=0.00025
    for t = T:-1:3 #3 because can't graduate until junior year at earliest
        if t==endperiod
            print("fvgrad ending early at t=",t,"\n")
            return (FVGw = FV0Gw, FVGb = FV0Gb)
        end
        esst  = 0:min(2*t,CapS)
        c4st  = 0:min(t,Cap4)
        state = merge(state, (age = (t-1),))
        state = merge(state, (repayflag = (state.age≤(TR+debthoriz-1)) && (state.age>(TR-1)),)) # range over which they repay their loan (TR+1 until TR+debthoriz)
        PWG   = pw(stype,t,1,lamcoef) # need to use age+1 instead of age since PW is from the standpoint of t+1
        FVGw .= FV0Gw
        FVGb .= FV0Gb
        for es = esst #white collar experience
            state = merge(state, (exper_white_collar = es/2,))
            eust  = 0:min(min(2*t,CapTot)-es,CapU) #0:min(2*t-es,CapU)
            for eu = eust #blue collar experience
                state = merge(state, (exper = (eu+es)/2,))
                for lc = 5:-1:1 #lagged choice
                    state = merge(state, (prev_PT  = any(in.(lc, [3, 4])),))
                    state = merge(state, (prev_FT  = any(in.(lc, [1, 2])),))
                    state = merge(state, (prev_WC  = any(in.(lc, [2, 4])),))
                    USC   = getSC(state.grad_4yr,strucb,state)
                    for maj = 1:2 #major
                        state = merge(state, (finalMajorSci = (maj==2),))
                        for c4 = c4st # 4 year college experience
                            state = merge(state, (cum_4yr = c4,))
                            c2st  = 0:min(min(t,CapCTot)-c4,Cap2)
                            for c2 = c2st # 2 year college experience
                                state = merge(state, (cum_2yr = c2,))
                                # debt payment
                                princ = state.cum_2yr*fastconsump.E_loan2_18 + state.cum_4yr*fastconsump.E_loan4_18
                                state = merge(state, (loanrepay = amortization(princ,a.intrate,debthoriz),))
                                for ggt=1:numgrid # labor market state
                                    state = merge(state, (gggrid = ggt,))
                                    state = merge(state, (ggt = pistb[ggt],))

                                    # code won't work as expected if debt horizon goes beyond last period
                                    if T1+debthoriz>T
                                        @show T
                                        @show T1
                                        @show debthoriz
                                        throw("Error: repayment horizon needs to be smaller than or equal to capital T")
                                    end

                                    # flow control utility based on loan repayment horizon (repay if T1+1 ≤ t ≤ (T1+debthoriz))
                                    if t==T && lc==5
                                        # compute flow utility for non-repayment periods
                                        statetilde1 = deepcopy(state)
                                        statetilde1 = merge(statetilde1, (repayflag = false,)) # everything is the same about the state except the repayment
                                        Uhold[:,ggt,eu+1,es+1,maj,c4+1,c2+1] = create_util(state.grad_4yr,Xfixed,fastconsump,stype,abilvec,a,statetilde1)[1:end-1]

                                        # compute flow utility for repayment periods
                                        statetilde2 = deepcopy(state)
                                        statetilde2 = merge(statetilde2, (repayflag = true,)) # everything is the same about the state except the repayment
                                        UholdR[:,ggt,eu+1,es+1,maj,c4+1,c2+1] = create_util(state.grad_4yr,Xfixed,fastconsump,stype,abilvec,a,statetilde2)[1:end-1]

                                        @assert statetilde1.repayflag==false
                                        @assert statetilde2.repayflag==true
                                    end

                                    if t≥TR+debthoriz+1
                                        U = vcat(Uhold[:,ggt,eu+1,es+1,maj,c4+1,c2+1], 0)
                                    elseif t≥TR+1 && t≤TR+debthoriz
                                        U = vcat(UholdR[:,ggt,eu+1,es+1,maj,c4+1,c2+1],0)
                                    else #t≤TR
                                        U = vcat(Uhold[:,ggt,eu+1,es+1,maj,c4+1,c2+1], 0)
                                    end
                                    v = get_v_g(U,USC,PWG,FVGw,FVGb,state,a)

                                    # compute FV and choice probabilities
                                    fwt,fbt,pwt,pbt = get_fv_g(v,bc,β)
                                    FV0Gw[ggt,eu+1,es+1,lc,maj,c4+1,c2+1] = fwt
                                    FV0Gb[ggt,eu+1,es+1,lc,maj,c4+1,c2+1] = fbt

                                    if t≤T1+1 # T1 is the horizon in which we track students' choices
                                        if t≤T1 # T1 is the horizon in which we track students' choices
                                            PChoiceGw[:     ,ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = pwt
                                            PChoiceGb[bc.==1,ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = pbt
                                        end

                                        # now do the init stuff
                                        # lc tracks in-college work sector
                                        # maj tracks in-college major
                                        v2=v-USC+getSCGinit(maj,strucb,state)

                                        # 1-FT BC; 2-FT WC; 3-PT BC; 4-PT WC; 5-Home
                                        fw2,fb2,pw2,pb2 = get_fv_g(v2,bc,β)
                                        if t≤T1 # T1 is the horizon in which we track students' choices
                                            PChoiceGinitw[:     ,ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = pw2
                                            PChoiceGinitb[bc.==1,ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = pb2
                                        end

                                        FVGinitw[ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = fw2
                                        FVGinitb[ggt,t,eu+1,es+1,lc,maj,c4+1,c2+1] = fb2
                                    end

                                    # manually garbage collect to prevent memory leak
                                    #rand() < thrd && GC.gc(true)
                                end
                            end
                        end
                    end
                end
            end
        end
        #Base.GC.gc(true)
    end

    return (PGw = PChoiceGw, PGb = PChoiceGb, PGiw = PChoiceGinitw, PGib = PChoiceGinitb, FVGiw = FVGinitw, FVGib = FVGinitb)
end

"""
    fvugrad(FVGinitw,FVGinitb,Xfixed,fastconsump,abil,stype,a,endperiod)

This function computes the future value terms for the graduate choice set

Inputs are:
FVGinitw and FVGinitb: future utility terms [with & without a white collar offer in the next period] from graduating
Xfixed: vector of fixed characteristics: intercept; black; hispanic; HS_grades; parent_college; birthYr
fastconsump: structure holding objects required to compute expected consumption [e.g. parental transfers, expected grants, tuition, expected loans, etc.]
abil: vector of abilities
stype: unobserved type (a number between 1 & S)
a: named tuple holding all parameters of the model and simulation
endperiod: period in which the program terminates and returns the current future value array (used for testing; default value is 1)

Functions the program calls:
pw: calculates white collar offer arrival probabilities
probgrad: calculates graduation probabilities
amortization: calculates loan repayment amounts
create_util: computes flow utilities

Lagged Choice matrix based on the following order of choices for those who have not graduated
1  2yr & FT; blue collar
2  2yr & FT; white collar
3  2yr & PT; blue collar
4  2yr & PT; white collar
5  2yr & No Work
6  4yr Science & FT; blue collar
7  4yr Science & FT; white collar
8  4yr Science & PT; blue collar
9  4yr Science & PT; white collar
10 4yr Science & No Work
11 4yr Humanities & FT; blue collar
12 4yr Humanities & FT; white collar
13 4yr Humanities & PT; blue collar
14 4yr Humanities & PT; white collar
15 4yr Humanities & No Work
16 Work PT; blue collar
17 Work PT; white collar
18 Work FT; blue collar
19 Work FT; white collar
20 Home

"""
function fvugrad(FVGinitw,FVGinitb,Xfixed,fastconsump,abil,stype,a,endperiod=0)
    # unpack parameter named tuple
    numgrid    = a.numgrid
    T          = a.T
    T1         = a.T1
    TR         = a.TR
    CapU       = a.CapU
    CapS       = a.CapSug
    CapTot     = a.CapTot
    Cap4       = a.Cap4
    Cap2       = a.Cap2
    CapCTot    = a.CapCTot
    pistb      = a.pistb
    β          = a.β
    S          = a.S
    strucb     = a.bstruc
    lamcoef    = a.boffer
    gbeta      = a.bgrad
    debthoriz  = a.debthorizon

    # initialize objects that will be used in the backwards recursion
    v     = zeros(20)
    bc    = [1;0;1;0;1;1;0;1;0;1;1;0;1;0;1;1;0;1;0;1] #choices that are available with no white collar offer
    bcT1  = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1] #choices that are available with no white collar offer after period T1
    wcT1  = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1] #choices that are available with a  white collar offer after period T1
    Uhld  = zeros(19,numgrid,CapU+1,CapS+1,Cap4+1,Cap2+1)
    UhldR = zeros(19,numgrid,CapU+1,CapS+1,Cap4+1,Cap2+1)
    #Uhlt = zeros(19,T1,numgrid,min(2*T1+1,CapU),min(2*T1+1,CapS),Cap4+1,Cap2+1)
    FVw   = zeros(numgrid,CapU+1,CapS+1,20,Cap4+1,Cap2+1)
    FVb   = zeros(numgrid,CapU+1,CapS+1,20,Cap4+1,Cap2+1)
    FV0w  = zeros(numgrid,CapU+1,CapS+1,20,Cap4+1,Cap2+1)
    FV0b  = zeros(numgrid,CapU+1,CapS+1,20,Cap4+1,Cap2+1)

    PChoicew = zeros(20,numgrid,T1,min(2*T1+1,CapU+1),min(2*T1+1,CapS+1),20,Cap4+1,Cap2+1) # T1 is T; 20 is J
    PChoiceb = zeros(20,numgrid,T1,min(2*T1+1,CapU+1),min(2*T1+1,CapS+1),20,Cap4+1,Cap2+1) # T1 is T; 20 is J
    PGrad    = zeros(20,Cap4+1,Cap2+1)                                                     # 20 is J

    #println("mem use (GB) in fvugrad after creating state matrices")
    #@show get_mem_use()
    #@show summarysize_gb(FVw)
    #@show summarysize_gb(FVb)
    #@show summarysize_gb(FV0w)
    #@show summarysize_gb(FV0b)
    #@show summarysize_gb(Uhld)
    #@show summarysize_gb(PChoicew)
    #@show summarysize_gb(PChoiceb)
    #@show summarysize_gb(PGrad)
    state = ( # named tuple
             exper              = 0.0,
             exper_white_collar = 0.0,
             finalMajorSci      = false,
             prev_HS            = false,
             prev_2yr           = false,
             prev_4yrS          = false,
             prev_4yrNS         = false,
             prev_PT            = false,
             prev_FT            = false,
             prev_WC            = false,
             cum_2yr            = 0,
             cum_4yr            = 0,
             age                = 0,
             ggt                = 0.0,
             gggrid             = 1,
             grad_4yr           = false,
             loanrepay          = 0.0,
             repayflag          = false
            )

    thrd=0.00025
    for t = T:-1:1
        if t==endperiod
            print("fvugrad ending early at t=",t,"\n")
            return (FVw = FV0w, FVb = FV0b)
        end
        esst  = 0:min(2*t,CapS)
        c4st  = 0:min(t,Cap4)
        state = merge(state, (age = (t-1),))
        state = merge(state, (repayflag = (state.age≤(TR+debthoriz-1)) && (state.age>(TR-1)),)) # range over which they repay their loan (TR+1 until TR+debthoriz)
        PW    = pw(stype,t,0,lamcoef) # need to use age+1 instead of age since PW is from the standpoint of t+1
        PWG   = pwg(stype,t,1,lamcoef) # need to use age+1 instead of age since PW is from the standpoint of t+1
        if t==1
            state = merge(state, (prev_HS = true,))
        else
            state = merge(state, (prev_HS = false,))
        end
        FVw .= FV0w
        FVb .= FV0b
        for es = esst # white collar experience
            state = merge(state, (exper_white_collar = es/2,))
            eust  = 0:min(min(2*t,CapTot)-es,CapU)
            for eu = eust # blue collar experience
                state = merge(state, (exper = (eu+es)/2,))
                for lc = 20:-1:1 # previous decision
                    if t>1
                        state = merge(state, (prev_2yr   = any(in.(lc,[1:5])),))
                        state = merge(state, (prev_4yrS  = any(in.(lc,[6:10])),))
                        state = merge(state, (prev_4yrNS = any(in.(lc,[11:15])),))
                        state = merge(state, (prev_PT    = any(in.(lc,[3, 4, 8, 9, 13, 14, 16, 17])),))
                        state = merge(state, (prev_FT    = any(in.(lc,[1, 2, 6, 7, 11, 12, 18, 19])),))
                        state = merge(state, (prev_WC    = any(in.(lc,[2, 4, 7, 9, 12, 14, 17, 19])),))
                    elseif t==1
                        state = merge(state, (prev_2yr   = false,))
                        state = merge(state, (prev_4yrS  = false,))
                        state = merge(state, (prev_4yrNS = false,))
                        state = merge(state, (prev_PT    = false,))
                        state = merge(state, (prev_FT    = false,))
                        state = merge(state, (prev_WC    = false,))
                    end
                    USC = getSC(state.grad_4yr,strucb,state)
                    for c4 = c4st # 4 year college experience
                        state = merge(state, (cum_4yr = c4,))
                        c2st  = 0:min(min(t,CapCTot)-c4,Cap2)
                        for c2 = c2st # 2 year college experience
                            state = merge(state, (cum_2yr = c2,))

                            # debt payment
                            princ = c2*fastconsump.E_loan2_18 + c4*fastconsump.E_loan4_18
                            state = merge(state, (loanrepay = amortization(princ,a.intrate,debthoriz),))

                            # graduation probability
                            PG = probgrad(Xfixed,stype,gbeta,abil,c2,c4)
                            PGrad[:,c4+1,c2+1] = PG

                            for ggt = 1:numgrid # grid for integral over future wage shocks [eq. 13 in the paper]
                                state = merge(state, (gggrid = ggt,))
                                state = merge(state, (ggt = pistb[ggt],))

                                # flow control utility based on loan repayment horizon (repay if T1+1 ≤ t ≤ (T1+debthoriz))
                                if t==T && lc==20
                                    # compute flow utility for non-repayment periods
                                    statetilde1 = deepcopy(state)
                                    statetilde1 = merge(statetilde1, (repayflag = false,))
                                    Uhld[:,ggt,eu+1,es+1,c4+1,c2+1] = create_util(state.grad_4yr,Xfixed,fastconsump,stype,abil,a,statetilde1)[1:end-1]

                                    # compute flow utility for repayment periods
                                    statetilde2 = deepcopy(state)
                                    statetilde2 = merge(statetilde2, (repayflag = true,))
                                    UhldR[:,ggt,eu+1,es+1,c4+1,c2+1] = create_util(state.grad_4yr,Xfixed,fastconsump,stype,abil,a,statetilde2)[1:end-1]

                                    @assert statetilde1.repayflag==false
                                    @assert statetilde2.repayflag==true
                                end
                                if t≤T1 && lc==20
                                    # Need this branch because we can't separate utility from age (because consumption depends on age through parental transfers)
                                    Uhld[:,ggt,eu+1,es+1,c4+1,c2+1] = create_util(state.grad_4yr,Xfixed,fastconsump,stype,abil,a,state)[1:end-1]
                                end

                                if t≥TR+debthoriz+1
                                    U = vcat(Uhld[:,ggt,eu+1,es+1,c4+1,c2+1], 0)
                                elseif t≥TR+1 && t≤TR+debthoriz
                                    U = vcat(UhldR[:,ggt,eu+1,es+1,c4+1,c2+1], 0)
                                else #t≤TR
                                    U = vcat(Uhld[:,ggt,eu+1,es+1,c4+1,c2+1], 0)
                                end

                                # compute choice-specific conditional value functions
                                v = get_v_ug(U,USC,PW,PWG,PG,FVw,FVb,FVGinitw,FVGinitb,state,a)

                                # compute FV and choice probabilities
                                fwt,fbt,pwt,pbt = get_fv_ug(v,bc,bcT1,wcT1,β,t,T1)
                                FV0w[ggt,eu+1,es+1,lc,c4+1,c2+1] = fwt
                                FV0b[ggt,eu+1,es+1,lc,c4+1,c2+1] = fbt
                                if t≤T1
                                    PChoicew[:     ,ggt,t,eu+1,es+1,lc,c4+1,c2+1] = pwt
                                    PChoiceb[bc.==1,ggt,t,eu+1,es+1,lc,c4+1,c2+1] = pbt
                                end

                                # manually garbage collect to prevent memory leak
                                #rand() < thrd && GC.gc(true)
                            end
                        end
                    end
                end
            end
        end
    end

    return (Pw = PChoicew, Pb = PChoiceb, pgrad = PGrad)
end


"""
    innerloop(i,obsvbls,fstcnsmp,ap)

This function subsets the data for individual i and calls the future value computation functions

Inputs are:
i: ID number of the individual
obsvbls: Array of time-invariant variables
fstcnsmp: DataFrame of consumption inputs
ap: Struct holding all parameters from estimation and all simulation parameters

"""
function innerloop(i,obsvbls,fstcnsmp,ap)
    # subset data to individual
    Xfixed=[1 obsvbls[i,1] obsvbls[i,2] obsvbls[i,3] obsvbls[i,4] obsvbls[i,5] obsvbls[i,6]] # constant, black, hispanic, HSgpa, parent_college, birthYr, famInc
    fstcnsmp = NamedTuple(k => v[i] for (k,v) in pairs(fstcnsmp))
    abil = abildrawer(ap.Δ) # note that indices differ from estimation; equal estimation[[5, 3, 4, 1, 2]]
    stype = typedrawer(ap.πτ)
    
    println("starting fvgrad")
    @time PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,FVGinitw,FVGinitb = fvgrad(stype,Xfixed,fstcnsmp,abil,ap)
    println("Time to compute grad counterfactual ↑ ")

    println("starting fvugrad")
    @time PChoicew,PChoiceb,PGrad = fvugrad(FVGinitw,FVGinitb,Xfixed,fstcnsmp,abil,stype,ap)
    println("Time to compute undergrad counterfactual ↑ ")

    # save simresults PChoice* FV* PGrad D Cap*
    return PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,PChoicew,PChoiceb,PGrad,abil,stype,Xfixed
end

"""
    forwardsim(PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,PChoicew,PChoiceb,PGrad,stype,params)

This function performs the forward simulation to obtain choices from the policy functions (PChoice*)

Inputs are:
PChoiceGw: choice probability in graduate choice set conditional on receiving a white collar offer
PChoiceGb: choice probability in graduate choice set conditional on NOT receiving a white collar offer
PChoiceGinitw: choice probability in first period after college graduation, conditional on receiving a white collar offer
PChoiceGinitb: choice probability in first period after college graduation, conditional on NOT receiving a white collar offer
PChoicew: choice probability in non-graduate choice set conditional on receiving a white collar offer
PChoiceb: choice probability in non-graduate choice set conditional on NOT receiving a white collar offer
PGrad: probability of graduating
stype: unobserved type
params: struct holding all parameters from estimation and simulation

Functions the program calls:
pwsimple: calculates white collar offer arrival probabilities

"""

function forwardsim(PChoiceGw,PChoiceGb,PChoiceGinitw,PChoiceGinitb,PChoicew,PChoiceb,PGrad,stype,params)
    T1      = params.T1
    numgrid = params.numgrid
    S       = params.S
    boffer  = params.boffer

    # Forward simulate to get the observed choices:
    ObsChoice = zeros(T1+1)
    offer     = zeros(T1+1)
    experS    = zeros(T1+1)
    experU    = zeros(T1+1)
    cum4      = zeros(T1+1)
    cum2      = zeros(T1+1)
    gradInd   = zeros(T1+1)
    LgradInd  = zeros(T1+1)
    sciMaj    = 0
    lminit    = sample(collect([1:numgrid]...),1)
    lmtile    = zeros(T1+1)
    lmtile[1] = lminit[1]
    LY        = vcat(20,zeros(T1))
    # For those who have graduated the order of choices is 1-FT BC; 2-FT WC; 3-PT BC; 4-PT WC; 5-Home
    wcgidx    = [2 4]
    wcidx     = [2 4 7 9 12 14 17 19]
    gbcidx    = setdiff(collect([1:5]...),wcgidx)
    ngbcidx   = setdiff(collect([1:20]...),wcidx)

    for t=1:T1
        # convert state values to indices
        es = 2*experS[t] |> (yyy -> convert(Int, yyy))
        eu = 2*experU[t] |> (yyy -> convert(Int, yyy))
        c4 = cum4[t]     |> (yyy -> convert(Int, yyy))
        c2 = cum2[t]     |> (yyy -> convert(Int, yyy))
        lc = LY[t]       |> (yyy -> convert(Int, yyy))
        lm = lmtile[t]   |> (yyy -> convert(Int, yyy))

        # get white collar offer probability
        offer[t] = 1 #rand()<pwsimple(stype,t,gradInd[t],boffer)
        if (LgradInd[t]==0 && any(in.(LY[t],wcidx))) || (LgradInd[t]==1 && any(in.(LY[t],wcgidx))) # if prev worked in white collar
            offer[t] = 1
        end

        # generate choices
        if gradInd[t]==0
            if offer[t]==1
                P = PChoicew[:,lm,t,eu+1,es+1,lc,c4+1,c2+1]
            else
                P = PChoiceb[:,lm,t,eu+1,es+1,lc,c4+1,c2+1]
            end
            ObsChoice[t] = choicedrawer(P,offer[t],ngbcidx)
        elseif LgradInd[t]==0 && gradInd[t]==1
            # lcint re-indexes the previous choice into what it needs to be to transition from the undergrad to grad sets. 5 indices are: workFT BC, workFT WC, workPT BC, work PT WC, no work
            lcint  = 1*any(in.(LY[t],[1 6 11 18])) + 2*any(in.(LY[t],[2 7 12 19])) + 3*any(in.(LY[t],[3 8 13 16])) + 4*any(in.(LY[t],[4 9 14 17])) + 5*any(in.(LY[t],[5 10 15 20]))
            maj    = 1*any(in.(LY[t],11:15)) + 2*any(in.(LY[t],6:10)) # 1 if graduated from humanities, 2 if graduated from sciences
            sciMaj = maj-1
            # draw choices given probabilities
            if offer[t]==1
                P = PChoiceGinitw[:,lm,t,eu+1,es+1,lcint,maj,c4+1,c2+1]
            else
                P = PChoiceGinitb[:,lm,t,eu+1,es+1,lcint,maj,c4+1,c2+1]
            end
            ObsChoice[t] = choicedrawer(P,offer[t],gbcidx)
        elseif LgradInd[t]==1 && gradInd[t]==1
            maj = 1*(sciMaj==0) + 2*(sciMaj==1)
            # draw choices given probabilities
            if offer[t]==1
                P = PChoiceGw[:,lm,t,eu+1,es+1,lc,maj,c4+1,c2+1]
            else
                P = PChoiceGb[:,lm,t,eu+1,es+1,lc,maj,c4+1,c2+1]
            end
            ObsChoice[t] = choicedrawer(P,offer[t],gbcidx)
        end

        # update state variables
        #experS[t+1],experU[t+1],cum4[t+1],cum2[t+1],gradInd[t+1],LgradInd[t+1],lmtile[t+1],LY[t+1] = state_update(ObsChoice[t],gradInd[t],experS[t],experU[t],cum4[t],cum2[t],lmtile[t],PGrad,params)
        nexperS,nexperU,ncum4,ncum2,ngrad,nLgrad,nlmtile,nLY = state_update(ObsChoice[t],gradInd[t],experS[t],experU[t],c4,c2,lmtile[t],PGrad,params)
        experS[t+1]   = nexperS 
        experU[t+1]   = nexperU 
        cum4[t+1]     = ncum4 
        cum2[t+1]     = ncum2 
        gradInd[t+1]  = ngrad
        LgradInd[t+1] = nLgrad
        lmtile[t+1]   = nlmtile
        LY[t+1]       = nLY
    end

    # re-index graduate choice alternatives to match with the index from estimated model
    # For those who have graduated the order of choices is 1-FT BC; 2-FT WC; 3-PT BC; 4-PT WC; 5-Home
    # In the estimated model, these were 16-PT BC; 17-PT WC; 18-FT BC; 19-FT WC; 20-Home
    ObsChoiceFinal = deepcopy(ObsChoice)
    for t=1:T1
        if gradInd[t]==1 && ObsChoice[t]==1
            println("replaced a value")
            ObsChoiceFinal[t]=18
        elseif gradInd[t]==1 && ObsChoice[t]==2
            println("replaced a value")
            ObsChoiceFinal[t]=19
        elseif gradInd[t]==1 && ObsChoice[t]==3
            println("replaced a value")
            ObsChoiceFinal[t]=16
        elseif gradInd[t]==1 && ObsChoice[t]==4
            println("replaced a value")
            ObsChoiceFinal[t]=17
        elseif gradInd[t]==1 && ObsChoice[t]==5
            println("replaced a value")
            ObsChoiceFinal[t]=20
        end
    end
    LYfinal = vcat(20*ones(1),ObsChoiceFinal[1:T1-1])
    return ObsChoiceFinal,gradInd,LYfinal,offer,lmtile
end

end # end of @views @inbounds
