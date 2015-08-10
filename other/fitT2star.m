function y = fitT2star(beta,x) %same as fitT2
y = beta(1)*exp(-x/beta(2));
end