function y = fitT1Inv(beta,x)
y = beta(3) - beta(1)*exp(-x*beta(2));
end