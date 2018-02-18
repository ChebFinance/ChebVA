# CounterpartyRisk

%---------------------------------------------------------------------
%
% GenerateTrade
%
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
%---------------------------------------------------------------------
% GenerateUnderlying
%
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
%---------------------------------------------------------------------
%
% GenerateCorrelation
%
% Description: Generates the structure that contains the correlation
% information.
%
% Input:    mRho, a correlation matrix. 
%           cellListUnderlyings, list of names of counterparties sorted in
%           agreement with mRho.
%
% Output:   Structure with mRho and cellListUnderlyings
%
% Notes: The correlation matrix has spot information on the first half and 
% vol information on the second half.
%---------------------------------------------------------------------
%
% GenerateCounterparty
%
% Description: Generates a structure with the counterparty information.
%
% Input: strUnderlying, string with the counterparty name.
%        stcDefault, structure with the default information
%           .default_type, string that indicates the functino PD=f(mSpot)
%           .paramX, parameters of the function PD = f(mSpot)
%
% Output: stcCounterparty, strucute with the inputs plus 
%            .mSpot
%            .mPDs
%         empty matrices that later will be filled with spot/PD informaion.
% 
%---------------------------------------------------------------------
%
% fMCWrapper
%

% Description: fMCWrapper calculates risk measures on the portfolio of all underlyings
% for the given counterparty. In particular, it handles the correlaction between the 
% underlyings. fMCWrapper invokes fMCJob, which runs a counterparty risk simulation on
% one (and only one!) underlying.
%
% Inputs:   cellUnderlyings, cell that contains a number of structures,
%                           each for one underlying.
%           cellTrades, cell with information of all the trades, each of
%                       them a structures (i.e. this is the trades book).
%           stcCpty, structure that contains the information of the single 
%                   counterparty, for which risk measures are calculated.
%           stcSimParams, structure with all the simulation parameters
%           (i.e. parameters not specific to cpty, trades or underlyings).
%           stcCorrelation, structure with correlation matrix and list of
%                           underlyings in the correct order related to the 
%                           correlation matrix.
%
% Output:   stcMeasures, structure with risk measures, calculated by
%                        calculate_RiskMeasures().
%           stcCpty, structure with counterparty information including
%                        mSpot and mPDs.
%           cellUnderlyings, cell with modified underlyings (i.e mSpot and
%                        mVol).
%           cellTrades, cell with modified trades (i.e. mPrices).
%
% Notes: - You can have more underlyings than strictly needed by the trades
%          book (i.e cellTrades), but not the other way around.
%       - As of 08/06/12 this routine only handles one counterparty with one
%          netting set.
