function [stcStatParams, vReturns] = calculate_statparams(data,dt,date_start,date_end,type)
% Description:  Calculate the first four moments of the returns of a given 
% time series.
%
% Inputs:  
%           data, time series in a 2-column matrix (first column date in 
%                 YYYYMMDD format and second column is the data).
%           dt, interval for returns in units of intervals in data (e.g. if 
%               data has weekly data and dt = 1, calculated returns will 
%               weekly returns).
%           date_start, date in which analysis starts
%           date_end, date in which analysis ends 
%           type, "logreturns" or "absreturns" indicating type of return in
%               the calculation
%
% Output:  stcStatParams, structure with four momentums of the returns
%          vReturns, time series with returns.
% 
% Notes: The code assumes that the increment in the time series data 
%        is sorted ascending.

subdata = data((date_start-data(:,1))<=0,:);
pos = max(find((subdata(:,1)-date_end)<=0));
if pos+dt < size(subdata,1),
    subdata = subdata(1:pos+dt,:);
end

subdata = subdata(1:dt:end,:);
A = subdata(1:end-1,2);
B = subdata(2:end,2);

switch type
    case 'logreturns'
        vReturns = log(B./A);
        
    case 'absreturns'
        vReturns = B - A;
end

stcStatParams.mu1 = mean(vReturns);
stcStatParams.mu2 = std(vReturns);
stcStatParams.mu3 = skewness(vReturns);
stcStatParams.mu4 = kurtosis(vReturns);
hist(vReturns,100)
%stcStatParams