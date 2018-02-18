function stcMCJobParams = GenerateMCJobParams(stcUnderlying, stcSimParams)
% Description: Generates a structure with all the simulation parameters
% that will be used in the function fMCJob (that generates one MC
% simulation for a given underlying).
%
% Input: stcUnderlying, a structure with the underlying information
%               .rate_0
%               .eta
%               .theta
%               .vol_0
%               .vol_inf
%               .spot_0
%        stcSimParams, a structure with the simulation information
%               .sim_model
%               .scens
%               .t
%               .steps
%               .tvec
%               .dt
%
% Output: a structure with all the MCJob parameters
%
% Notes: Notice that the simulation model is the same for all underlyings.

stcMCJobParams.VolType  = stcSimParams.sim_model;
stcMCJobParams.rate_0   = stcUnderlying.rate_0;
stcMCJobParams.eta      = stcUnderlying.eta;
stcMCJobParams.theta    = stcUnderlying.theta;   % mean reversion speed of stochastic vol
stcMCJobParams.vol_0    = stcUnderlying.vol_0;
stcMCJobParams.vol_inf  = stcUnderlying.vol_inf; % mean reversion level of stochastic vol
stcMCJobParams.spot_0   = stcUnderlying.spot_0;
stcMCJobParams.scens    = stcSimParams.scens;
stcMCJobParams.t        = stcSimParams.t;
stcMCJobParams.steps    = stcSimParams.steps;
stcMCJobParams.tvec     = stcSimParams.tvec;
stcMCJobParams.dt       = stcSimParams.dt;