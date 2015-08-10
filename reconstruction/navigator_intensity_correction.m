function [kspace] = navigator_intensity_correction(kspace,nav_odd,nav_even,ref_scan,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
for z=1:param.nz
    for y=1:param.ny
        ref_scan(:,y,z) = fftshift(ifft(ref_scan(:,y,z)));
    end
    for t=1:param.nt
        nav_odd(:,z,t) = fftshift(ifft(nav_odd(:,z,t)));
        nav_even(:,z,t) = fftshift(ifft(nav_even(:,z,t)));
    end
end

odd_norm = squeeze(sum(sum(ref_scan(:,[1 3 5],:),1),2));
even_norm = squeeze(sum(sum(ref_scan(:,[2 4 6],:),1),2));

%%
gauss_1D = fspecial('gaussian',[45 1],11);
xx = round(1*param.knx/4):round(3*param.knx/4)-1;
nav_odd_mid = nav_odd(xx,:,:);
nav_even_mid = nav_even(xx,:,:);
for x=1:length(xx)
    for z=1:param.nz
        nav_odd_smooth(x,z,:) = imfilter(squeeze(nav_odd_mid(x,z,:)),gauss_1D);
        nav_even_smooth(x,z,:) = imfilter(squeeze(nav_even_mid(x,z,:)),gauss_1D);
        
    end
end
nav_odd_sum = squeeze(sum(nav_odd_smooth,1))./repmat(odd_norm,[1 param.nt]);
nav_even_sum = squeeze(sum(nav_even_smooth,1))./repmat(even_norm,[1 param.nt]);
if param.display
    figure
    subplot(2,1,1); imagesc(abs(squeeze(nav_even_mid(:,3,:)))); title('raw')
    subplot(2,1,2); imagesc(abs(squeeze(nav_even_smooth(:,3,:)))); title('smoothed')
    z=round(param.nz/2);
    figure
    subplot(2,1,1); plot(abs(nav_odd_sum(z,:))); title('odd')
    subplot(2,1,2); plot(abs(nav_even_sum(z,:))); title('even')
end


end