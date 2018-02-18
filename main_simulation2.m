tic
clear, clc

% --------------------------------------------------------------------
% Generate Correlation and Underlyings information
%
% In this block you must construct a correlation matrix, a list of
% underlyings, and a cell of underlyings. NOTICE that the three of them
% MUST be aligned!
%

% Generate a correlation matrix (if no WWR, mRho = diagonal_of_ones)

% Remember that the matrix is given in blocks, i.e, first diagonal block is
% the inter-spot correlations, second diagonal blocks is the inter-vol
% correlations, and anti-diagonal blocks are the spot-vol correlations.
%
% Input of correlation matrix is only an triangular matrix with ones on the
% diagonal.

mRho1 = [+1   +0.9  +0.0  -0.4  -0.4  -0.0; 
        +0.0  +1.0  +0.0  -0.4  -0.4  -0.0;
        +0.0  +0.0  +1.0  -0.0  -0.0  -0.0;
        +0.0  +0.0  +0.0  +1.0  +0.8  +0.0;
        +0.0  +0.0  +0.0  +0.0  +1.0  +0.0;
        +0.0  +0.0  +0.0  +0.0  +0.0  +1.0];
mRho2 = eye(6);

mRho = mRho1;
mRho = mRho + mRho' - eye(size(mRho));
 
% Generate list of underlyings 
stcListUnderlyings = {'Ford';'Repsol';'USD_YC'};

% Generate correlation structure (mRho + list of underlyings). Remember
% that mRho is aligned with the list of underlyings and that the first half 
% of mRho corresponds to spots and the second half to vols.
stcCorrelation = GenerateCorrelation(mRho,stcListUnderlyings);

% Generate structures for each underlying and store all in a cell
stcUnder1 = GenerateUnderlying('Ford',  10,0.05,0.0,0.8,0.3,3.8,1);
stcUnder2 = GenerateUnderlying('Repsol',10,0.05,0.0,0.5,0.3,3.8,1);
stcUnder3 = GenerateUnderlying('USD_YC',0.05,0.05,0.0,0.4,0.4,2.0,1.0);
cellUnderlyings = {stcUnder1;stcUnder2;stcUnder3};


% --------------------------------------------------------------------
% Generate structures for each trade and store all in a cell


%stcTrade1 = GenerateTrade('bsoptionput','Ford',100,5,10);
stcTrade1 = GenerateTrade('forward','Ford',0,3,10);
stcTrade2 = GenerateTrade('bsoptionput','Repsol',0,6,10);
stcTrade3 = GenerateTrade('IRswap','USD_YC',1,5,0.05);
cellTrades = {stcTrade1;stcTrade2;stcTrade3};
%cellTrades = {stcTrade3};


% --------------------------------------------------------------------
% Construct a structure for the Cpty.
stcDefault.default_type = 'NoWWR';
stcDefault.param1 = 1/3;
stcDefault.param2 = -1/0.37;   %-1/0.37
stcDefault.param3 = [];
stcDefault.param4 = [];
stcCpty = GenerateCounterparty('Ford',stcDefault);


% --------------------------------------------------------------------
% Define the simulation parameters
nNumSims = 5000;
t = 5;
dt = 10; %days per time steps
dnVar = 10; %MPR
stcSimParams = GenerateSimParams(nNumSims,t,dt,'constant',dnVar);
% Run !!!
[stcMeasuresCTE,stcCptyCTE,cellUnderlyingsCTE,cellTradesCTE] = fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);


% Define the simulation parameters
stcUnder3 = GenerateUnderlying('USD_YC',0.05,0.05,0.0,1.0,0.4,2.0,1.0);
cellUnderlyings = {stcUnder1;stcUnder2;stcUnder3};
stcSimParams = GenerateSimParams(nNumSims,t,dt,'BK',dnVar);
% Run !!!
[stcMeasuresBK1,stcCptyBK1,cellUnderlyingsBK1,cellTradesBK1] = fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);

% Define the simulation parameters
stcUnder3 = GenerateUnderlying('USD_YC',0.05,0.05,0.0,0.4,0.4,2.0,1.0);
cellUnderlyings = {stcUnder1;stcUnder2;stcUnder3};
stcSimParams = GenerateSimParams(nNumSims,t,dt,'BK',dnVar);
% Run !!!
[stcMeasuresBK2,stcCptyBK2,cellUnderlyingsBK2,cellTradesBK2] = fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);

% Define the simulation parameters
stcUnder3 = GenerateUnderlying('USD_YC',0.05,0.05,0.0,0.2,0.4,2.0,1.0);
cellUnderlyings = {stcUnder1;stcUnder2;stcUnder3};
stcSimParams = GenerateSimParams(nNumSims,t,dt,'BK',dnVar);
% Run !!!
[stcMeasuresBK3,stcCptyBK3,cellUnderlyingsBK3,cellTradesBK3] = fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);


%Calculate CVA
s_ctpy = 0.05;
s_mine = 0.005;
stcCVA_CTE = CalculateCVA(stcSimParams,stcMeasuresCTE,s_ctpy,s_mine);
stcCVA_BK1 = CalculateCVA(stcSimParams,stcMeasuresBK1,s_ctpy,s_mine);
stcCVA_BK2 = CalculateCVA(stcSimParams,stcMeasuresBK2,s_ctpy,s_mine);
stcCVA_BK3 = CalculateCVA(stcSimParams,stcMeasuresBK3,s_ctpy,s_mine);

% --------------------------------------------------------------------
% Plot

% Play here (plot, run again, etc).
tvec = stcSimParams.tvec;
tvecVaR = stcSimParams.tvecVaR;


subplot(2,3,1)
plot(tvecVaR,stcMeasuresCTE.Collat.EPE,'k')
ylim([0 0.02])

subplot(2,3,2)
plot(tvecVaR,stcMeasuresBK1.Collat.EPE,'g')
hold on
plot(tvecVaR,stcMeasuresBK2.Collat.EPE,'r')
plot(tvecVaR,stcMeasuresBK3.Collat.EPE,'b')
ylim([0 0.02])
hold off

% subplot(2,3,3)
% y = [CalculateIM(stcMeasuresCTE),CalculateIM(stcMeasuresBK1),CalculateIM(stcMeasuresBK2),CalculateIM(stcMeasuresBK3)];
% bar(y);

subplot(2,3,3)
y = [stcCVA_CTE.Collat,stcCVA_BK1.Collat,stcCVA_BK2.Collat,stcCVA_BK3.Collat];
bar(y);

subplot(2,3,4)
plot(tvec,stcMeasuresCTE.UnCollat.EPE,'r')
%hold on
%plot(tvec,stcMeasuresBK.UnCollat.EPE,'k')
ylim([0,0.05])
%hold off

subplot(2,3,5)
plot(tvec,stcMeasuresBK1.UnCollat.EPE,'g')
hold on
plot(tvec,stcMeasuresBK2.UnCollat.EPE,'r')
plot(tvec,stcMeasuresBK3.UnCollat.EPE,'b')
ylim([0,0.05])
hold off

subplot(2,3,6)
y = [stcCVA_CTE.UnCollat,stcCVA_BK1.UnCollat,stcCVA_BK2.UnCollat,stcCVA_BK3.UnCollat];
bar(y);









% COMPARE ONE METRIC BETWEEN WWR AND NO-WWR
% stcDefault.default_type = 'power';
% stcCpty = GenerateCounterparty('Ford',stcDefault);
% [stcMeasures2, stcCpty2,cellUnderlyings2,cellTrades2] = fMCWrapper(cellUnderlyings,cellTrades,stcCpty,stcSimParams,stcCorrelation);
% subplot(1,2,1)
% plot(tvec,stcMeasures1.UnCollat.EPE,'k')
% hold on
% plot(tvec,stcMeasures2.UnCollat.EPE,'b')
% ylim([0,1000])
% hold off
% subplot(1,2,2)
% plot(tvecVaR,stcMeasures1.Collat.EPE,'k')
% hold on
% plot(tvecVaR,stcMeasures2.Collat.EPE,'b')
% ylim([0 200])
% hold off

toc