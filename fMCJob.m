function [mSpot,mVol] = fMCJob(stcParams, mR1, mR2)
% Description: This is the core simulation engine for one single
% underlying, both the spot and volatility. 
%
% Inputs:   stcParams, structure with the following fields:
%               - rate_0  = double, drift for the spot model.
%               - eta     = double, vol of vol
%               - theta   = double, mean reversion speed of volatility
%               - vol_0   = double, volatility at simulation starting time
%               - vol_inf = double, mean reversion level paremeter. If
%                           stochastic vol model (OU or BK) this is the mean reversion
%                           level for instantaneous volatility. If deterministic
%                           exponential volatility (expTVol) this is the vol at t ->
%                           infinity.
%               - spot_0  = double, spot at simulation starting time
%               - scens   = integer, number of scenarios (number of rows of mSpot and mVol)
%               - t       = double, timel horizon of Monte Carlo simulation (units years)
%               - steps   = integer, number of simulation time steps (number of columns
%                           of mSpot and mVol is steps + 1)
%               - tvec    = vector with time buckets (calculated from t and steps if
%                           equispaced)
%               - dt      = double, size of time steps when equispaced
%               - VolType = string indicating the volatility simulation
%                           model:
%                          * 'constant', constant volatility
%                          * 'expTVol', deterministic vol following single exponential formula
%                          * 'BK', stochastic vol following Black-Karasinski model
%                          * 'OU', stochastic vol following
%                                   Ornsted-Unberlach
%           mR1, matrix of standar normally distributed random numbers that
%               are used for the evolution of mSpot. Size scens x steps.
%           mR2, matrix of standar normally distributed random numbers that
%               are used for the evolution of mVol. Size scens x steps.
%
% Output:   mSpot, matrix of size scens x steps+1 that contains the Monte
%                  Carlo simulation of the spot.
%           mVol, matrix of size scens x steps+1 that contains the Monte
%                  Carlo simulation of the volatility.
% 
% Notes: Matrices mR1 and mR2 can be constructed with a desired correlation 
% by using the function CorrelMatrices.

% extract parameters from structure stcParams
scens = stcParams.scens;
steps = stcParams.steps;   
vol_0 = stcParams.vol_0;
tvec = stcParams.tvec;
dt = stcParams.dt;
VolType = stcParams.VolType;


% compute volatility matrix mVol according to the model
switch VolType
    case 'constant'
        mVol = vol_0*ones(scens,steps+1);
    case 'expTVol'        
        theta = stcParams.theta;
        vol_inf = stcParams.vol_inf;         
        mVol = (vol_0-vol_inf)*exp(-theta*tvec) + vol_inf;
        mVol = mVol(ones(scens,1),:);
    case 'BK'               
        theta = stcParams.theta;
        vol_inf = stcParams.vol_inf;
        eta = stcParams.eta;
        mVol = zeros(scens,steps+1);
        mVol(:,1) = vol_0*ones(scens,1);        
        for k = 2:steps+1
            exp1 = exp( log(mVol(:,k-1))*exp(-theta*dt) );
            exp2 =  exp( (log(vol_inf) - (eta^2)/(4*theta) )*(1-exp(-theta*dt)));
            exp3 = exp(eta*sqrt((1-exp(-2*theta*dt))/(2*theta))*mR2(:,k-1));
            mVol(:,k) = exp1.*exp2.*exp3;
                   
        end
    case 'OU'               
        theta = stcParams.theta;
        vol_inf = stcParams.vol_inf;
        eta = stcParams.eta;
        mVol = zeros(scens,steps+1);
        mVol(:,1) = vol_0*ones(scens,1);
        
        for k = 2:steps+1
        mVol(:,k) = mVol(:,k-1)*exp(-theta*dt) + vol_inf*(1-exp(-theta*dt)) + ...
            eta*sqrt((1-exp(-2*theta*dt))/(2*theta))*mR2(:,k-1);
        end        
    otherwise
        disp('Unknown volatility method.');
end

% Computes the spots using a GBM model with mVol as volatility.
spot_0 = stcParams.spot_0;
rate_0 = stcParams.rate_0;

mSpot = zeros(scens,steps+1);
mSpot(:,1) = spot_0*ones(scens,1);

for k = 2:steps+1
    % the variance at each time steps is computed as the mean of the
    % variances between the previous and the current time steps:
    mVol_average = sqrt(0.5*(mVol(:,k).^2 + mVol(:,k-1).^2));
    
    mSpot(:,k) = mSpot(:,k-1).*exp((rate_0-.5*mVol_average.^2).*dt + ...
        sqrt(dt)*mVol_average.*mR1(:,k-1));
end

