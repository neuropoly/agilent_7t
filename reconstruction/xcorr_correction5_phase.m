function [ fftxksP,RY ] = xcorr_correction5_phase(kspace,refspace,param)
% Global phase correction with linear interpolation on the reference scans

%%
Rodd = refspace(:,1:2:end-1,:);
Reven = refspace(:,2:2:end,:);
for t=1:param.nt
    for z=1:param.knz
        for y=1:param.ny
            fftxksP(:,y,z,t) = fftshift(ifft(kspace(:,y,z,t)));
        end
    end
end
for z=1:param.knz
    for y=1:param.ny/2
        Rodd(:,y,z) = fftshift(ifft(Rodd(:,y,z)));
        Reven(:,y,z) = fftshift(ifft(Reven(:,y,z)));
    end
end
x=round(2*param.knx/8):round(6*param.knx/8)-1;
Rodd1D = reshape(Rodd(x,:,:),length(x)*param.ny/2,param.knz);
Reven1D = reshape(Reven(x,:,:),length(x)*param.ny/2,param.knz);
xx=1:size(Rodd1D,1);
min_inc=-5;
max_inc=5;
inc=0.05;
increment=min_inc:inc:max_inc;
for z=1:param.knz
    for ii=increment
        counter = round((ii-min_inc)/inc+1);
        xi=xx+ii;
        intRodd1D(:,z,counter) = interp1(xx,Rodd1D(:,z),xi);
        intRodd1D(isnan(intRodd1D))=0;
        [fitobjectangleit{z,counter},gofangle{z,counter}] = fit(double(unwrap(angle(intRodd1D(:,z,counter)))),double(unwrap(angle(Reven1D(:,z)))),'poly1');
        gofanglecrit(z,counter)=gofangle{z,counter}.adjrsquare;
    end
    %     [~,maxfitabs(z)]=max(gofabscrit(z,:));
    [~,maxfitangle(z)]=max(gofanglecrit(z,:));
    Rodd1D(:,z)=intRodd1D(:,z,maxfitangle(z));
    %     fitobjectabs{z}=fitobjectabsit{z,maxfitabs(z)};
    fitobjectangle{z}=fitobjectangleit{z,maxfitangle(z)};
    if param.display
        figure
%         plot(gofabscrit(z,:)); % hold on;
        plot(gofanglecrit(z,:),'g'); hold off; title('goodness of fit');
        figure
        %             subplot(2,1,1);
        plot(abs(Rodd1D(:,z)))
        hold on; plot(abs(Reven1D(:,z)),'g'); hold off
        %             subplot(2,1,2); plot(angle(Rodd1D(:,z)))
        %             hold on; plot(angle(Reven1D(:,z)),'g'); hold off
    end
    for y=1:param.ny/2
%         RYabs(:,y,z) = feval(fitobjectangle{z},abs(Rodd(:,y,z)));
        RYangle(:,y,z) = feval(fitobjectangle{z},angle(Rodd(:,y,z)));
        RYa(:,y,z) = abs(Rodd(:,y,z)).*cos(RYangle(:,y,z));
        RYb(:,y,z) = abs(Rodd(:,y,z)).*sin(RYangle(:,y,z));
        RY(:,y,z) = complex(RYa(:,y,z),RYb(:,y,z));
    end
    if param.display
        figure
        subplot(2,2,1); plot(abs(Reven(:,1,z))); title('Original abs')
        hold on; plot(abs(Rodd(:,1,z)),'g');
        subplot(2,2,2); plot(abs(Reven(:,1,z))); title('Fitted abs')
        hold on; plot(RYabs(:,1,z),'g'); hold off
        subplot(2,2,3); plot(angle(Reven(:,1,z))); title('Original angle')
        hold on; plot(angle(Rodd(:,1,z)),'g');
        subplot(2,2,4); plot(angle(Reven(:,1,z))); title('Fitted angle')
        hold on; plot(RYangle(:,1,z),'g'); hold off
    end
    for t=1:param.nt
        for y=1:2:param.ny-1
            Yangle(:,y,z,t) = feval(fitobjectangle{z},angle(fftxksP(:,y,z,t)));
            Ya(:,y,z,t) = abs(fftxksP(:,y,z,t)).*cos(Yangle(:,y,z,t));
            Yb(:,y,z,t) = abs(fftxksP(:,y,z,t)).*sin(Yangle(:,y,z,t));
            fftxksP(:,y,z,t) = complex(Ya(:,y,z,t),Yb(:,y,z,t));
        end
    end
end

end

