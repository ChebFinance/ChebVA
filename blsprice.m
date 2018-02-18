function [call,put] = blsprice(mSpot,K,r,t,mVol,div_yield)

d1 = (log(mSpot./K) + (r+0.5*mVol.^2).*t)./(mVol.*sqrt(t));
d2 = d1 - mVol.*sqrt(t);
call = mSpot .* normcdf(d1) - K .* normcdf(d2) .* exp(-r .* t);
put = normcdf(-d2).*K.*exp(-r.*t)-normcdf(-d1).*mSpot;


end

