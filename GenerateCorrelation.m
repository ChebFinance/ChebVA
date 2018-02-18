function stcCorrelation = GenerateCorrelation(mRho, cellListUnderlyings)
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

stcCorrelation.mRho = mRho;
stcCorrelation.cellListUnderlyings = cellListUnderlyings;

numUnique = numel(cellListUnderlyings);
[mC,nC] = size(mRho);
if (mC~=nC) || (mC ~= 2*numUnique)
    error('Correlation matrix has wrong size.')
end
