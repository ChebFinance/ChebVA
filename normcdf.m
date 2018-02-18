function f = normcdf(x,mu,sigma)

if nargin==1, mu = 0; sigma = 1; end

f = 0.5*(1+erf((x-mu)/(sigma*sqrt(2))));
