function y = expT2star(beta,x)
%beta(1): a constant
%beta(2): T2star, to be determined
%x: echo time
y = beta(1)*exp(-x/beta(2));
end