

A = 0.9999;
lambda = 0.1;
T = -10;

B = (1-A)/(1-exp(lambda*T));
C = (A-exp(lambda*T))/(1-exp(lambda*T));

f = @(x) (1-A)*x+A;
t = @(x) (log(f(x)-C) - log(B))/lambda;
plot(sort(t(rand(1000,1))),'.')