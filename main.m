% Calculation of counterparty risk profiles and CVA for three trades:
%   - a forward on Ford
%   - a put option on Repsol
%   - an IR swap on USD

clear, clc
% --------------------------------------------------------------------
% Generate structures for each underlying and store all in a cell. 

undl1 = 'Ford'; undl2 = 'Repsol'; undl3 = 'USD_YC';
spot1 = 10.00; spot2 = 10.00; spot3 = 10.00;
rate1 =  0.05; rate2 =  0.05; rate3 =  0.05; 
divy1 =  0.00; divy2 =  0.00; divy3 =  0.00;
voli1 =  0.80; voli2 =  0.50; voli3 =  0.40;
vole1 =  0.30; vole2 =  0.30; vole3 =  0.40; 
thet1 =  3.80; thet2 =  3.80; thet3 =  2.00; 
eta1 =   1.00; eta2 =   1.00; eta3 =   1.00;

stcUnder1 = GenerateUnderlying(undl1, spot1, rate1, divy1, voli1, vole1, thet1, eta1);
stcUnder2 = GenerateUnderlying(undl2, spot2, rate2, divy2, voli2, vole2, thet2, eta2);
stcUnder3 = GenerateUnderlying(undl3, spot3, rate3, divy3, voli3, vole3, thet3, eta3);

cellUnderlyings = {stcUnder1;stcUnder2;stcUnder3};

% Generate a correlation matrix of the spot and vols between the underlyings
% (if no WWR, mRho = diagonal_of_ones).
%
% Remember that the matrix is given in blocks, i.e, first diagonal block is
% the inter-spot correlations, second diagonal blocks is the inter-vol
% correlations, and anti-diagonal blocks are the spot-vol correlations.
%
% Input of correlation matrix is only an triangular matrix with ones on the
% diagonal.

mRho = [+1   +0.9  +0.0  -0.4  -0.4  -0.0; 
        +0.0  +1.0  +0.0  -0.4  -0.4  -0.0;
        +0.0  +0.0  +1.0  -0.0  -0.0  -0.0;
        +0.0  +0.0  +0.0  +1.0  +0.8  +0.0;
        +0.0  +0.0  +0.0  +0.0  +1.0  +0.0;
        +0.0  +0.0  +0.0  +0.0  +0.0  +1.0];
% make the matrix symmetric
mRho = mRho + mRho' - eye(size(mRho));

% Generate correlation structure (mRho + list of underlyings). Remember
% that mRho is aligned with the list of underlyings and that the first half 
% of mRho corresponds to spots and the second half to vols.

stcListUnderlyings = {undl1; undl2; undl3};
stcCorrelation = GenerateCorrelation(mRho,stcListUnderlyings);
% -------------------------------------------------------------------
% Generate structures for each trade and store all in a cell

N1 = 10; T1 = 4; K1 = 10; % notional, maturity and strike
N2 = 10; T2 = 3; K2 = 10;
N3 = 10; T3 = 2; K3 = 0.05;
stcTrade1 = GenerateTrade('forward',undl1, N1, T1, K1);
stcTrade2 = GenerateTrade('bsoptionput',undl2, N2, T2, K2);
stcTrade3 = GenerateTrade('IRswap',undl3, N3, T3, K3);

cellTrades = {stcTrade1;stcTrade2;stcTrade3};
% --------------------------------------------------------------------
% Construct a structure for the Cpty.
stcDefault.default_type = 'NoWWR';
stcDefault.param1 = 1/3;
stcDefault.param2 = -1/0.37;
stcDefault.param3 = [];
stcDefault.param4 = [];
stcCpty = GenerateCounterparty('Ford',stcDefault);

% --------------------------------------------------------------------
% Define the simulation parameters

nNumSims = 5000;        % number of scenarios 
t = 5;                  % end of the simulation in years
dt = 10;                % number of days per simulation step
dnVar = 10;             % number of days for collateralized risk
sim_model = 'constant'; % volatility model (constant, expTVol, BK, OU)

stcSimParams = GenerateSimParams(nNumSims,t,dt,sim_model,dnVar);

% --------------------------------------------------------------------

[stcMeasures,stcCpty,cellUnderlyings,cellTrades] = ...
    fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);

s_ctpy = 0.050; % spread of counterparty
s_mine = 0.005; % my spread

stcCVA = CalculateCVA(stcSimParams,stcMeasures,s_ctpy,s_mine);
display(['Uncollateralized CVA: ', num2str(stcCVA.UnCollat)])
LW = 'linewidth';
tvec = stcSimParams.tvec;
tvecVaR = stcSimParams.tvecVaR;

plot(tvec, stcMeasures.UnCollat.EPE,  LW, 2), hold on,
plot(tvec, stcMeasures.UnCollat.ENE,  LW, 2), hold off
grid on