function y = fitT1(beta,x)
y = beta(3) - beta(1)*exp(-x/beta(2));
end