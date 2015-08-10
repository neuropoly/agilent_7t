function [kspace] = xcorr_navigator(kspace,nav_odd,nav_even,param)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
for t=1:param.nt
    for z=1:param.knz
        for y=1:param.ny
            kspace(:,y,z,t) = fftshift(ifft(kspace(:,y,z,t)));
        end
    end
end
for t=1:param.nt
    for z=1:param.nz
        nav_odd(:,z,t) = fftshift(ifft(nav_odd(:,z,t)));
        nav_even(:,z,t) = fftshift(ifft(nav_even(:,z,t)));
    end
end
x=round(2*param.knx/8):round(6*param.knx/8)-1;
navP_odd1D = nav_odd(x,:,:);
navP_even1D = nav_even(x,:,:);
xx=1:size(navP_odd1D,1);
min_inc=-1;
max_inc=1;
inc=0.05;
increment=min_inc:inc:max_inc;
for t=1:param.nt
    for z=1:param.knz
        for ii=increment
            counter = round((ii-min_inc)/inc+1);
            xi=xx+ii;
            intnavP_odd1D(:,z,counter) = interp1(xx,navP_odd1D(:,z),xi);
            intnavP_odd1D(isnan(intnavP_odd1D))=0;
            [fitobjectabsit{z,counter},gofabs{z,counter}] = fit(double(abs(intnavP_odd1D(:,z,counter))),double(abs(navP_even1D(:,z))),'poly1');
            gofabscrit(z,counter)=gofabs{z,counter}.adjrsquare;
        end
        [~,maxfitabs(z)]=max(gofabscrit(z,:));
        navP_odd1D(:,z)=intnavP_odd1D(:,z,maxfitabs(z));
        fitobjectabs{z}=fitobjectabsit{z,maxfitabs(z)};
        if param.display
            figure
            plot(gofabscrit(z,:));
            figure
            plot(abs(navP_odd1D(:,z)))
            hold on; plot(abs(navP_even1D(:,z)),'g'); hold off
        end
        for y=1:2:param.ny-1
            Yabs(:,y,z,t) = feval(fitobjectabs{z},abs(kspace(:,y,z,t)));
            Ya2(:,y,z,t) = Yabs(:,y,z,t).*cos(angle(kspace(:,y,z,t)));
            Yb2(:,y,z,t) = Yabs(:,y,z,t).*sin(angle(kspace(:,y,z,t)));
            kspace(:,y,z,t) = complex(Ya2(:,y,z,t),Yb2(:,y,z,t));
        end
    end
end
% 
% navN_odd = permute(shiftdim(navi.N_odd,-1),[2 1 3 4]);
% navN_even = permute(shiftdim(navi.N_even,-1),[2 1 3 4]);
% navN = [navN_odd navN_even];

end

