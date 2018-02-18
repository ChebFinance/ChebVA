function mMatrixVaR = calculate_mMatrixVaR(mMatrix,dnVaR,T,tvec)
% Constructs a matrix MMATRIXVAR of size scens x (nstesps - dnVaR) with the
% differences of the matrix every dnVaR days. dnVaR is an integer number.
% If dnVaR is not provided, it is assumed to be 10. 
%
% NOTICE: It is assumed that the time steps in MMATRIX are daily and
% equispaced. Further versions will use arbitrary grids.

if nargin == 1 
    dnVaR = 10;
end
P1 = mMatrix(:,1:end-dnVaR);

indxT = min(find(T<tvec))-1;
mMatrixT = mMatrix(:,indxT);

mMatrix2 = mMatrix;
mMatrix2(:,[indxT+1:indxT+dnVaR]) = repmat(mMatrixT,1,dnVaR);

P2 = mMatrix2(:,dnVaR+1:end);

mMatrixVaR =  P2 - P1;