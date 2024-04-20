using Random, LinearAlgebra, Statistics, Distributions, Test

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

# unit tests
# set up test case
Xfix = [1 0 0 1.46 1 1980 37]
typer = 1
prabilstr = zeros(5)
allparm = (testme = [3.14 149], bgrad = [-3.5569 -0.8336 -0.4845 0.2528 -0.0244 0.6053 0.3292 0.3530 0.4986 0.0171 0.4581 0.5202 1.3548 1.7381 2.7283 0.7677 0.9047 -2.8054 -0.5739 2.1635 1.3599 -0.3363 1.8478 1.3506 -0.0630 0.3610 -0.0959 0.7830 -0.0428])
states = (cum_2yr = 0, cum_4yr = 0)
out = flowutilgprob(Xfix,typer,prabilstr,allparm,states)

# test 1: check that the function returns a vector of length 19
@test length(out) == 19

# test 2: check that function returns numbers in the unit interval
@test all((out .>= 0) .& (out .<=1)) == true

# test 3: check that function returns a vector of zeros when c2+c4<2
states = (cum_2yr = 0, cum_4yr = 1)
out = flowutilgprob(Xfix,typer,prabilstr,allparm,states)
@test all(out .== 0) == true
states = (cum_2yr = 0, cum_4yr = 1)
out = flowutilgprob(Xfix,typer,prabilstr,allparm,states)
@test all(out .== 0) == true
states = (cum_2yr = 1, cum_4yr = 0)
out = flowutilgprob(Xfix,typer,prabilstr,allparm,states)
@test all(out .== 0) == true

# test 3: check that function returns appropriate values when c2+c4>2
states = (cum_2yr = 1, cum_4yr = 3)
out = flowutilgprob(Xfix,typer,prabilstr,allparm,states)
@test all(out[:, 1:5 ] .== 0) == true
@test all(out[:, 6:15] .>  0) == true
@test all(out[:, 6:15] .<  1) == true
@test all(out[:,16:19] .== 0) == true
