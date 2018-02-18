function stcTrade = GenerateTrade(strInstrument, strUnderlying, Notional, T, K)
% Description: Generates a structure with the information of a trade
% (e.g., optioncall, forward, etc) and all the relevant data.
%
% Input: strInstrument, a string with the product name (e.g. "forward",
%                       "optioncall",etc)
%        strUnderlying, a string with the name of the underlying (e.g.
%                       "Vodafone", "GBPUSD", "WTI")
%        Notional, number with notional (in units required by the specific
%                       trade pricer)
%        T, number with time to maturity in years
%        K, number with strike
%
% Ouput: a structure stcTrade with all the inputs plus
%
%        mPrice, empty field to be filled with the matrix of prces of the
%               trade
%
% Notes: 


stcTrade.strInstrument = strInstrument; % e.g., 'forward'
stcTrade.strUnderlying = strUnderlying; % e.g., 'Vodafone'
stcTrade.Notional = Notional;
stcTrade.T = T;
stcTrade.K = K;
stcTrade.mPrice = [];