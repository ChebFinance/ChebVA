function mPD = calculate_PDs(stcCounterparty)
% Description: Calculates the Default Probabilities per scenario and time
% step for a counterparty. 
%
% Input: stcCounterparty, structure with the following fields
%           .default_type: string that determines PD as a function of mSpot
%                          (NoWWR, log, exp or power).
%           .mSpot: matrix of underlying that drives the default event
%           .param1: parameters of the function mPD = f(mSpot)
%           .param2: parameters of the function mPD = f(mSpot)
%           .param3: parameters of the function mPD = f(mSpot)
%           .param4: parameters of the function mPD = f(mSpot)
%
% Output: mPD, a matrix with the probability of default per scenario and
% time step.
%
% Note: To see the possible function see the switch in the code.

default_type = stcCounterparty.default_type;
mSpot = stcCounterparty.mSpot;
param1 = stcCounterparty.param1;
param2 = stcCounterparty.param2;
param3 = stcCounterparty.param3;
param4 = stcCounterparty.param4;


switch default_type
    case 'NoWWR'
        mPD = ones(size(mSpot));
    case 'log'
        mPD = param1*log(mSpot) + param2;
    case 'exp'
        mPD = param1*exp(param2*mSpot);
    case 'power'
        mPD = param1*mSpot.^param2;
end



if sum(sum( (mPD<=0)|(mPD>1))) ~=0 
    warning('Some of the obtained PDs are either negative or greater than one.')
    mPD(find(mPD<=0)) = 1e-4;
    mPD(find(mPD>1)) = 1;
end