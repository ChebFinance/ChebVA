function stcStats = display_histogram(mSpot,tvec,step_0, step_number,type)
% Description: Display histogram for a a vector of log returns.
%
% Inputs:   mSpot, matrix of prices of size (num scens) x (num steps +1)  
%                 (all values must be positive) 
%           tvec, vector of size (num steps + 1) associated with time axes 
%                 of mSpot
%           step_0, column of mSpot used as a reference for log change
%                  calculation
%           step_number, column of mSpot at which the log change is 
%                        calculated from step_0 (values start at zero). 
%           type, 'normalised' or 'unnormalised'. It tells if the plots are
%               normalised or not.
%
% Outputs:  A plot with histogram and the normal distribution on top
%           stcStats, a structure with the first four moments of the
%           histogram (mu1,...,mu4).
%
% Notes: The bin for the histogram is not fixed but computed dynamically in
% each calculation. This will be modified in later versions in such a way
% that the normal distribution is computed accordingly and the bins are
% fixed.
%
% Default values for limited nargin are the following: 
%           step_0 = 1; step_number = last, type = 'normalised' 

BLUE = [0.39 0.47 0.65];

if nargin == 2
    step_number = size(mSpot,2)-1;
    type = 'normalised';
    step_0 = 1;
    
end
if nargin == 3
    type = 'normalised';
    step_number = size(mSpot,2)-1;
end

if nargin ==4
    type = 'normalised';
end
if step_0 >= step_number
    error('Step_0 must be smaller than step_number')
end

if step_number == 1
    error('STEP_NUMBER == 1 implies all spots have the same value; no histogram or statistical values are computed')
end
t = tvec(step_number);



logmSpot = log(mSpot(:,step_number+1)./mSpot(:,step_0));
mean_logmSpot = mean(logmSpot);
std_logmSpot = std(logmSpot);
skew_logmSpot = skewness(logmSpot);
kurtosis_logmSpot = kurtosis(logmSpot);


stcStats.mu1 = mean_logmSpot;
stcStats.mu2 = std_logmSpot;
stcStats.mu3 = skew_logmSpot;
stcStats.mu4 = kurtosis_logmSpot;


switch type
    case 'normalised'
        lim_xx = 5; 
        step_xx = 2*lim_xx/100;
        xx = -lim_xx:step_xx:lim_xx;

        logmSpot_xx = logmSpot/(std_logmSpot);
        [n, h] = hist(logmSpot_xx,xx);
        bar(h,n/(step_xx*length(logmSpot)));


        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',BLUE,'EdgeColor',BLUE)
        hold on

        cdf_xx = normcdf(xx,0,1);
        pdf_xx = (1/step_xx)*[cdf_xx(1) diff(cdf_xx)];
        plot(xx,pdf_xx,'k','linewidth',2)
        hold off,
    case 'unnormalised'
        lim_xx = max(abs(logmSpot));
        step = 2*lim_xx/100;

        xx = -lim_xx:step:lim_xx;
        hist(logmSpot,xx);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','w','EdgeColor','k')
        test_vol = std_logmSpot;
        hold on
        yy = size(mSpot,1)*step*normpdf(xx,0,test_vol);
        plot(xx,yy,'k','linewidth',2)
        hold off,
end 


