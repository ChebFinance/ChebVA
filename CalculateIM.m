function rIM = CalculateIM(stcMeasures)
% Description: Calcualtes the Initial Margin of a trade
%
% Input:    stcMeasures, structure that contains the EPE and ENE profiles,
%                       both collat and uncollateralised
%
% Ouput:    rIM, the initial margin
%
% Notes: 	The Initial Margin is the max of the PFE99 (collateralised)
%                       profile

rIM = max(stcMeasures.Collat.PFE99);
