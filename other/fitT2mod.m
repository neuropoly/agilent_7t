function y = fitT2mod(beta,x)
y = beta(1)*exp(-x/beta(2))+beta(3);
end