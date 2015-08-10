function y = expAbsT1(beta,x)
%beta(1): a constant
%beta(2): T1, to be determined
%beta(3): TR, a constant
%x: inversion time TI
y = abs((beta(2)-beta(3))*exp(-x/beta(1))+beta(3));