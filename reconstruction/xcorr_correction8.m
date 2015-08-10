function [fftxksP] = xcorr_correction8(kspace,param)
% Individual global phase correction with linear interpolation on each scan

%%
for t=1:param.nt
    for z=1:param.knz
        for y=1:param.ny
            fftxksP(:,y,z,t) = fftshift(ifft(kspace(:,y,z,t)));
        end
    end
end
odd_fftxksP = fftxksP(:,1:2:end-1,:,:);
even_fftxksP = fftxksP(:,2:2:end,:,:);
x=round(2*param.knx/8):round(6*param.knx/8)-1;
odd_fftxksP1D = reshape(odd_fftxksP(x,:,:),length(x)*param.ny/2,param.knz,param.nt);
even_fftxksP1D = reshape(even_fftxksP(x,:,:),length(x)*param.ny/2,param.knz,param.nt);
xx=1:size(odd_fftxksP1D,1);
min_inc=-5;
max_inc=5;
inc=0.05;
increment=min_inc:inc:max_inc;
for t=1:param.nt
    for z=1:param.knz
        for ii=increment
            counter = round((ii-min_inc)/inc+1);
            xi=xx+ii;
            intodd_fftxksP1D(:,z,t,counter) = interp1(xx,odd_fftxksP1D(:,z,t),xi);
            intodd_fftxksP1D(isnan(intodd_fftxksP1D))=0;
            [fitobjectabsit{z,t,counter},gofabs{z,counter}] = fit(double(abs(intodd_fftxksP1D(:,z,t,counter))),double(abs(even_fftxksP1D(:,z,t))),'poly1');
            gofabscrit(z,t,counter)=gofabs{z,counter}.adjrsquare;
        end
        [~,maxfitabs(z,t)]=max(gofabscrit(z,t,:));
        odd_fftxksP1D(:,z,t)=intodd_fftxksP1D(:,z,t,maxfitabs(z,t));
        fitobjectabs{z,t}=fitobjectabsit{z,t,maxfitabs(z,t)};
        if param.display
            figure
            plot(gofabscrit(z,:));
            figure
            plot(abs(odd_fftxksP1D(:,z)))
            hold on; plot(abs(even_fftxksP1D(:,z)),'g'); hold off
        end
        for y=1:2:param.ny-1
            Yabs(:,y,z,t) = feval(fitobjectabs{z,t},abs(fftxksP(:,y,z,t)));
            Ya2(:,y,z,t) = Yabs(:,y,z,t).*cos(angle(fftxksP(:,y,z,t)));
            Yb2(:,y,z,t) = Yabs(:,y,z,t).*sin(angle(fftxksP(:,y,z,t)));
            fftxksP(:,y,z,t) = complex(Ya2(:,y,z,t),Yb2(:,y,z,t));
        end
    end
end

end

