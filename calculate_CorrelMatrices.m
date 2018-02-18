function mOutput = calculate_CorrelMatrices(scens,steps,mrho)
% Description:
% Returns n matrices of random matrices (standard) normally distributed 
% dimension scens x steps with each member correlated by mrho.
% Inputs:
%   n: number of matrices
%   scens: number of scenarios
%   steps: number of time steps
%   mrho: correlation matrix of nxn
% Outputs:
%   mOutput: Cube of n matrices, each of scens x steps. The dimensions are
%   (n,scens,steps)
% Notes:
% Correlation is given between the (i,j)-elements of the n matrices, hence
% the correlation matrix is n x n.
% If you want to extract a slice of mOutput (i.e., one of the n matrices),
% use the following command:
% 
%   mtempk = reshape(mOutput(k,:,:),scens,steps);
% for the kth matrix.
%
% When parallel computing was intruduced, the for loop was changed to a
% parfor loop, and the cube mOutput(:,j,k) had to be reduced to a matrix
% like mOutput(:,i), where i goes from 1 to scens*steps, and then the cube
% is build from mOutput(:,i).

[m,n] = size(mrho);

if m~=n, error('Correlation matrix must be square.'), end


mA = chol(mrho);
mAt = mA';


parfor i = 1 : scens * steps
    mOutput(:,i) = mAt * randn(n,1);
end
mOutput = reshape(mOutput,[n,scens,steps]); %for some unknown reason, the code seems to work perfectly if this line is commeted out (!!)



%CODE BEFORE PARALLEL COMPUTING WAS INTRUDUCED
%To run it comment out the parfor loop and the reshape of the mOutput, and comment this back in
% mOutput = randn(n,scens,steps);
% for k = 1:steps
%    for j = 1:scens
%        vec = mOutput(:,j,k);
%        vec = mA'*vec;
%        mOutput(:,j,k) = vec;
%    end
% end


