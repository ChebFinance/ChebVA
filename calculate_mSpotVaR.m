function mSpotVaR = calculate_mSpotVaR(mMatrix,dnVaR,T,tvec)
% Constructs a matrix MMATRIXVAR of size scens x (nstesps - dnVaR) with the
% differences of the matrix every dnVaR days. dnVaR is an integer number.
% If dnVaR is not provided, it is assumed to be 10. 
%
% NOTICE: It is assumed that the time steps in MMATRIX are daily and
% equispaced. Further versions will use arbitrary grids.

if nargin == 1 
    dnVaR = 10;
end

if nargin <= 2
    mMatrixVaR = mMatrix(:,dnVaR+1:end) - mMatrix(:,1:end-dnVaR);    
else
    if size(mMatrix,2) ~= length(tvec)
       error('Number of columns of matrix must be equal length of t');
    end   
    mMatrixVaR = mMatrix(:,dnVaR+1:end) - mMatrix(:,1:end-dnVaR);  
    
    near_expiry = (tvec <= T) .* (tvec >= (T-dnVaR) );

    indx_near_expiry = find(near_expiry);
    
    indx_T = max(indx_near_expiry);
    
    mMatrixVaR(:,indx_near_expiry) = mMatrix(:,indx_near_expiry) + ...
        repmat(mMatrix(:,indx_T),1,length(indx_near_expiry));