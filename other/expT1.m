function y = expT1(beta,x)
%beta(1): a constant
%beta(2): T1, to be determined
%beta(3): TR, a constant
%x: inversion time TI
TR = 4000; %in milliseconds
y = beta(1)*(1-2*exp(-x/beta(2))+exp(-TR/beta(2)));
%y = beta(1)*(1-2*exp(-x/beta(2)));
end