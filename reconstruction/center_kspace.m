function [IprimePc,IprimeNc,param] = center_kspace(IprimeP,IprimeN,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Center kspace
param.central_positionx = round(param.knx/2);
param.central_positiony = round(param.kny/2);
if param.center_kspace==1
    disp(['centering kspace with param.center_kspace = ' num2str(param.center_kspace)])
    gauss_1D = fspecial('gaussian',[11,1],2);
    kscrushedt = abs(mean(IprimeP,4));
    kscrushedy = abs(mean(kscrushedt(:,round(3*param.kny/8):round(5*param.kny/8),:),2));
    kscrushedysmoothed = imfilter(kscrushedy,gauss_1D);
    [~,central_freq] = max(kscrushedysmoothed,[],1); central_freq=squeeze(central_freq);
    for t=1:param.nt
        for z=1:param.knz
            IprimePc(:,:,z,t) = circshift(IprimeP(:,:,z,t),param.central_positionx-central_freq(z));
        end
    end
    kscrushedt = abs(mean(IprimeN,4));
    kscrushedy = abs(mean(kscrushedt(:,round(3*param.kny/8):round(5*param.kny/8),:),2));
    kscrushedysmoothed = imfilter(kscrushedy,gauss_1D);
    [~,central_freq] = max(kscrushedysmoothed,[],1); central_freq=squeeze(central_freq);
    for t=1:param.nt
        for z=1:param.knz
            IprimeNc(:,:,z,t) = circshift(IprimeN(:,:,z,t),param.central_positionx-central_freq(z));
        end
    end
elseif param.center_kspace==2
    disp(['centering kspace with param.center_kspace = ' num2str(param.center_kspace)])
    gauss_2D = fspecial('gaussian',[11,11],3);
    kssmoothed=imfilter(abs(IprimeP),gauss_2D,'same');
    for t=1:param.nt
        for z=1:param.knz
            cent = find(kssmoothed(:,:,z,t)==max(max(kssmoothed(:,:,z,t))));
            central_pix = [mod(cent,param.knx) ceil(cent/param.knx)];
            IprimePcx(:,:,z,t) = circshift(IprimeP(:,:,z,t),param.central_positionx-central_pix(1));
            IprimePc(:,:,z,t) = circshift(IprimePcx(:,:,z,t)',param.central_positiony-central_pix(2))';
        end
    end
    kssmoothed=imfilter(abs(IprimeN),gauss_2D,'same');
    for t=1:param.nt
        for z=1:param.knz
            cent = find(kssmoothed(:,:,z,t)==max(max(kssmoothed(:,:,z,t))));
            central_pix = [mod(cent,param.knx) ceil(cent/param.knx)];
            IprimeNcx(:,:,z,t) = circshift(IprimeN(:,:,z,t),param.central_positionx-central_pix(1));
            IprimeNc(:,:,z,t) = circshift(IprimeNcx(:,:,z,t)',param.central_positiony-central_pix(2))';
        end
    end
    clear IprimePcx IprimeNcx
else
    IprimePc=IprimeP;
    IprimeNc=IprimeN;
end

% Display centering
if param.display
    z=param.knz; t=param.nt;
%     for t=1:param.nt
        figure(2)
        subplot(2,2,1); imagesc(log(abs(IprimeP(:,:,z,t)))); title(['IprimeP z=' num2str(z) ' t=' num2str(t)]);
        subplot(2,2,2); imagesc(log(abs(IprimePc(:,:,z,t)))); title(['IprimePc z=' num2str(z) ' t=' num2str(t)]);
        subplot(2,2,3); imagesc(log(abs(IprimeN(:,:,z,t)))); title(['IprimeN z=' num2str(z) ' t=' num2str(t)]);
        subplot(2,2,4); imagesc(log(abs(IprimeNc(:,:,z,t)))); title(['IprimeNc z=' num2str(z) ' t=' num2str(t)]);
        %         pause;
%     end
end

end

