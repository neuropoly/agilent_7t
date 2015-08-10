function y = expT1_VFA(beta,x)
%beta(1): the slope, which is exp(-T1/TR)
%beta(2): a constant
y = beta(1)*x + beta(2);