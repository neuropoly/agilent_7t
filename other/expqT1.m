function y = expqT1(beta,x)
%beta(1): a constant
%beta(2): T1, to be determined
%beta(3): TR, a constant
%x: inversion time TI
y = beta(2)*(1-2*beta(3)*exp(-x/beta(1)));