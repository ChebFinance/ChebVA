function stcMeasures = calculate_RiskMeasures(mPrices,mWeights)
% Description: Given a matrix of prices and a matrix of weights, this
% function calculates a series of risk measures.
%
% Inputs:   mPrices, matrix of prices by scenarios x time
%           mWeights, a matrix of weights by scenarios x time
%
% Outputs:  stcMeasures, a structure with risk profiles. As 05/2012 the
%                       following measures are obtained:
%           EPE
%           ENE
%           MTM
%           EEE (the regulatory Effective EPE profile)
%           PFE01, PFE05, PFE10,
%           PFE90, PFE95, PFE99,
%           ESF01, ESF05, ESF10,
%           ESF90, ESF95, ESF99,
%
% Notes: See also "calculate_PercentileMeasures".

W = sum(mWeights,1);
mWeightedPrices = mPrices.*mWeights;

MTM = sum(mWeightedPrices,1)./W;

mFlooredPrices = mPrices;
mFlooredPrices(mFlooredPrices<0) = 0;
mWeightedFlooredPrices = mFlooredPrices.*mWeights;
EPE = sum(mWeightedFlooredPrices,1)./W;

ENE = MTM - EPE;
stcMeasures.ENE = ENE;
stcMeasures.EPE = EPE;
stcMeasures.MTM = MTM;

[stcMeasures.PFE01,stcMeasures.ESF01] = calculate_PercentileMeasures(mPrices,mWeights,0.01);
[stcMeasures.PFE05,stcMeasures.ESF05] = calculate_PercentileMeasures(mPrices,mWeights,0.05);
[stcMeasures.PFE10,stcMeasures.ESF10] = calculate_PercentileMeasures(mPrices,mWeights,0.10);

[stcMeasures.PFE90,~,stcMeasures.ESF90] = calculate_PercentileMeasures(mPrices,mWeights,0.90);
[stcMeasures.PFE95,~,stcMeasures.ESF95] = calculate_PercentileMeasures(mPrices,mWeights,0.95);
[stcMeasures.PFE99,~,stcMeasures.ESF99] = calculate_PercentileMeasures(mPrices,mWeights,0.99);

% Effective EPE
EEE = EPE;
for i=1:length(EPE)
    if i==1
        EEE(i) = EEE(i);
    else
        EEE(i) = max(EEE(i),EEE(i-1));
    end
end
stcMeasures.EEE = EEE;

