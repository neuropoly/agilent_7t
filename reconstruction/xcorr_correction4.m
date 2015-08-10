function [ kspace,refspace ] = xcorr_correction4(kspace,refspace,param)
% Odd and even echoes mismatch correction using the cross correlation on 
% the reference scans

%%
x=1:param.knx;
for z=1:param.knz
    odd = mean(refspace(:,[1 3],z),2);
    even = mean(refspace(:,[2 4],z),2);
    cross_corr = xcorr(odd,even);
    precise_max_z(z) = precise_max(cross_corr,param);
    precise_max_z(z) = precise_max_z(z)-param.knx/2;
end
for z=1:param.knz
    for y=2:2:param.ny
        for t=1:param.nt
            Y=kspace(:,y,z,t);
            xi=(1:param.knx) + param.central_position - precise_max_z(z);
            kspace(:,y,z,t) = interp1(x,Y,xi);
        end
        Y=refspace(:,y,z);
        xi=(1:param.knx) + param.central_position - precise_max_z(z);
        refspace(:,y,z) = interp1(x,Y,xi);
    end
end
kspace(isnan(kspace)) = 0;    %eliminate the NaN
refspace(isnan(refspace)) = 0;

end

