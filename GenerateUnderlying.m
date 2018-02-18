function stcUnderlying = GenerateUnderlying(strUnderlying,  spot_0, rate_0, div_yield,  vol_0, vol_inf, theta, eta)
% Description: Generates a structure with the information of the
% underlying.
%
% Input:    strUnderlying, string with underlying (e.g. "Vodafone",
%                          "GBPUSD", "WTI", etc)
%           spot_0, value of underlying at start of simulation
%           rate_0, value of interest rate at start of simulation
%           div_yield,  value of yield of the underlying
%           vol_0, value of instantaneous volatility at start of simulation
%           vol_inf, value of instantaneous volatility at infinity
%           theta, value of mean reversion speed if mean reverting model in
%                  stochastic volatility
%           eta, value of vol of vol if stochastic volatility
%
% Ouput: a structure stcUnderlying with all the inputs plus
%
%           mSpot, empty field that will be filled with spot simulation 
%           mVol, empty field that will be filled with vol simulation
%
% Notes:

stcUnderlying.strUnderlying = strUnderlying;
stcUnderlying.spot_0 = spot_0;
stcUnderlying.rate_0 = rate_0;
stcUnderlying.vol_0 = vol_0;
stcUnderlying.vol_inf = vol_inf;
stcUnderlying.theta = theta;
stcUnderlying.eta = eta ;
stcUnderlying.mSpot = [];
stcUnderlying.mVol = [];
stcUnderlying.div_yield = div_yield;