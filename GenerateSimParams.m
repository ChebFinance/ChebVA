function stcSimParams = GenerateSimParams(scens,t,DaysPerStep,sim_model,dnVaR)
% Description: Generates a structure with the simulation parameters.
%
% Input:    scens, number of scenarios 
%           t, end of the simulation in years
%           DaysPerStep, number of days per simulation step
%           sim_model, string with vol model "constant", "expTVol", "BK", "OU"
%           dnVaR, number of days for the collateralized risk.
%
% Output:    stcSimParams, a structure that contains input information plus 
%               tvec,   vector with all the time points (equidistant) of length 
%                       steps+1
%               tvecVaR,vector with all the time points (equidistant) for
%                       the collateralised profiles
%               dt,     size of each time step in years
%               nDaysPerYear, Num of days per year
%               steps,  Number of time steps in the uncollateralised simulation
%               CollatStepsJumps, number of simulations jumps that are used
%                                 to calculated the collateralised VaR numbers
%
% Notes:    nDaysPerYear has been hardcodd to 260 as at Jun 2012.
%           t is adjusted, a little bit larger, to ensure the simulation is
%               at least as long as the inputed "t".
%           The code has been design so that dnVar must be a multiple of
%               DaysPerStep. If not, it throughs an error. This can be
%               modified later if wanted.

nDaysPerYear = 260;
stcSimParams.nDaysPerYear = nDaysPerYear;
stcSimParams.scens = scens;
stcSimParams.nDaysPerStep = DaysPerStep;
steps = floor(t*nDaysPerYear/DaysPerStep)+1;
stcSimParams.steps = steps;
stcSimParams.t = steps*DaysPerStep/nDaysPerYear;
stcSimParams.sim_model = sim_model;
stcSimParams.dnVaR = dnVaR;

CollatStepsJump = dnVaR/DaysPerStep;
stcSimParams.CollatStepsJump = CollatStepsJump;
if CollatStepsJump - floor(CollatStepsJump)~=0 
    error('dnVar must be a multiple of DaysPerStep.')
end

tvec = linspace(0,t,steps+1);
stcSimParams.tvec = tvec;
stcSimParams.tvecVaR = tvec(1:end-CollatStepsJump);
stcSimParams.dt = t/steps;