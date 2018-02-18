function [vPFE,vESF_Neg, vESF_Pos] = calculate_PercentileMeasures(mPrices,mWeights,rX)
% Description: Given some prices, weights and a percentage value, it
% calculates PFE and ESF (+ and -). 
%
% Inputs:   mPrices, matrix of prices by scenarios x time
%           mWeights, a matrix of weights by scenarios x time
%           rX, a percentile value (e.g 0.95)
%
% Outpus:   vPFE, a vector with PFE profile
%            vESF_Neg, a vector with Expected Shortfall profile  from 
%                      -infty to quantile(rX)
%            vESF_Pos, a vector with Expected Shorfall profile  from 
%                       quantile(rX) to infinity
%
% Notes:   mPrices and mWeights must have the same size.
%          Notice that linear interpolation is used in the percentile 
%          calculation except when rX is smaller than the smallest
%          cumulated weight scenario.

steps = size(mPrices,2)-1;
vPFE = zeros(1,steps+1);
vESF_Neg = zeros(1,steps+1);
vESF_Pos = zeros(1,steps+1);

for k = 1:steps+1
    PW = sortrows([mPrices(:,k) mWeights(:,k)],1);
    normalized_cumW = cumsum(PW(:,2))./sum(PW(:,2));
    % pctile_pos is the first position on normalized_cumW that is strictly
    % greater than rX:
    pctile_pos = min(find(normalized_cumW>=rX));
    
    
    if pctile_pos == 1
    %   directly take the P indicated by pctile_pos
        vPFE(k) = PW(pctile_pos,1);
    else
    %   interpolate the P values based in normalized_cumW:
        vPFE(k) = (rX-normalized_cumW(pctile_pos-1))*...
            (PW(pctile_pos,1)-PW(pctile_pos-1,1))/...
            (normalized_cumW(pctile_pos) - normalized_cumW(pctile_pos-1)) + ...
            PW(pctile_pos-1,1);
    end
    
    vESF_Neg(k) = mean(PW(1:pctile_pos-1,1));
    vESF_Pos(k) = mean(PW(pctile_pos:end,1));
end

% we floor PFE to zero

vPFE(vPFE<0)=0;