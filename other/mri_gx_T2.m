function y = ioi_gx_hrf_3gamma(x,u,p,M)
dt = 1; %M.Y.dt;
y = p(9)*(spm_Gpdf(x,p(1)/p(3),dt/p(3)) - spm_Gpdf(x,p(2)/p(4),dt/p(4))*p(5) + spm_Gpdf(x,p(6)/p(7),dt/p(7))*p(8));
