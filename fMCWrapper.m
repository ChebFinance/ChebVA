function [stcMeasures,stcCpty,cellUnderlyings,cellTrades] = fMCWrapper(cellUnderlyings, cellTrades, stcCpty, stcSimParams, stcCorrelation)
% Description: fMCJob runs a counterparty risk simulation
% for one (and only one) underlying. On the other hand, this routine calls fMCJob many 
% times to calculate risk measures on the portfolio of all underlyings for 
% the given counterparty. Moreover, it handles the correlation between the
% underlyings. 
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
%       - This routine is equivalent to QSF in QuIC. 



%--------------------------------------------------------------------------
% 1. Creat list of underlyings in which we run the MC simulation
% Output
%   cellListUnderlyings: unique list of underlyings to run MC simulation
%   numUnderlyings: number of unique underlyings to run MC simulation
%
% Note
%   Any underlying that exists in cellUnderlyings but doesn't exist in
%   cellTrades or stcCpty is not in the output (therefore is not
%   MC-simulated).


% Create a list of underlyings from Trades and Counterparty
cellListUnderlyings = stcCorrelation.cellListUnderlyings;
numTrades = numel(cellTrades);

% Initialize the cell temp_cellTradesUnderlyings with numTrades+1 elements
% (the extra one comes from the stcCpty).
temp_cellTradesUnderlyings = cell(numTrades+1,1);
for k = 1:numTrades
    temp_cellTradesUnderlyings{k} = cellTrades{k}.strUnderlying;
end
temp_cellTradesUnderlyings{numTrades+1} = stcCpty.strUnderlying;


% We create a unique list of underlyings.
tempUnique = { temp_cellTradesUnderlyings{1} };
for k = 2:numTrades+1
    CurrentUnderlying = temp_cellTradesUnderlyings{k};
    numtempUnique = numel(tempUnique);
    boolA = 0;
    for j = 1:numtempUnique
        if strcmp(CurrentUnderlying,tempUnique{j})
            boolA = 1; 
            break;
        end
    end
    if boolA == 0,
        tempUnique{numtempUnique+1} = CurrentUnderlying;
    end
end
numUnderlyings = numel(cellListUnderlyings);
numtempUnique = numel(tempUnique);

% Check that the unique list of underlyings is the same as the list of
% underlyings from the Correlation.
for k = 1:numUnderlyings
    boolA = 0;
    for j = 1:numtempUnique
        if strcmp(cellListUnderlyings{k},tempUnique{j})
            boolA = 1;
            break;
        end
    end
    if boolA == 0
        error('Underlyings in the list of trades/counterparty is not contained in the list of correlations.')
    end
end
for k = 1:numtempUnique
    boolA = 0;
    for j = 1:numUnderlyings
        if strcmp(cellListUnderlyings{j},tempUnique{k})
            boolA = 1;
            break;
        end
    end
    if boolA == 0
        error('List of underlyings in the structure of correlations is not contained in the list of trades/counterparty.')
    end
end

%--------------------------------------------------------------------------
% 2. Generate mSpot and mVol for each underlying


scens = stcSimParams.scens;
steps = stcSimParams.steps;
mRho = stcCorrelation.mRho;
% Generate a three-dimension matrix with the R's (standard normally
% distributed correlated-by-mRho random matrices).
mCorrelatedRs = calculate_CorrelMatrices(scens,steps,mRho);

%   a. we iterate underlyings in UniqueUnderlyings
%   b. for the given underlying, find the position in the correlation cell
%   c. we extract R1 and R2 from mCorrelatedRs
%   d. then we run the MC model on that underlying with such R's
%   e. finally we place the spot and vol simulation matrices in the 
%      underlying structure.

for k = 1:numUnderlyings
    strCurrentUnderlying = cellListUnderlyings{k};
    for j = 1:numel(cellUnderlyings)
        if strcmp(strCurrentUnderlying,cellUnderlyings{j}.strUnderlying)
            R1 = reshape(mCorrelatedRs(k,:,:), scens,steps);
            R2 = reshape(mCorrelatedRs(numUnderlyings+k,:,:), scens,steps);
            stcMCJobParams = GenerateMCJobParams(cellUnderlyings{j},stcSimParams);
            [mSpot,mVol] = fMCJob(stcMCJobParams, R1, R2);
            cellUnderlyings{j}.mSpot = mSpot;
            cellUnderlyings{j}.mVol = mVol;
            break;
        end
    end
end

% ------------------------------------------------------------------------
% 3. Price each trade

for k = 1:numel(cellTrades)
    strCurrentUnderlying = cellTrades{k}.strUnderlying;
    for j = 1:numel(cellUnderlyings)
        if strcmp(strCurrentUnderlying,cellUnderlyings{j}.strUnderlying)
            stcCurrentUnderlying = cellUnderlyings{j};
            break;
        end
    end
    cellTrades{k}.mPrice = price_trade(cellTrades{k},stcCurrentUnderlying, stcSimParams); 
end

%------------------------------------------------------------------------

% 4. Sum prices

mSumPrices = zeros(scens,steps+1);
for k = 1:numel(cellTrades)
    mSumPrices = mSumPrices + cellTrades{k}.mPrice;
end

% ------------------------------------------------------------------------

% 5. Generate PD = f(stcCpty.mSpot)

for k = 1:numel(cellUnderlyings)
    strCurrentUnderlying = cellUnderlyings{k}.strUnderlying;
    if strcmp(strCurrentUnderlying,stcCpty.strUnderlying)
        stcCpty.mSpot = cellUnderlyings{k}.mSpot;
        break;
    end
end

stcCpty.mPDs = calculate_PDs(stcCpty);

%------------------------------------------------------------------------
% 6. Collateralized calculations

[mCollatPrices, mCollatPDs] = calculate_CollatPricesAndPDs(mSumPrices,stcCpty.mPDs,stcSimParams);


%------------------------------------------------------------------------
% 7. Risk measures.

stcMeasures.UnCollat = calculate_RiskMeasures(mSumPrices,stcCpty.mPDs);
stcMeasures.Collat = calculate_RiskMeasures(mCollatPrices,mCollatPDs);



