function [] = glm_epi_display(rspace,tmap,output,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

T1s = mean(rspace,4);
%T1s = T1s(end:-1:1,end:-1:1,:);
Y2 = permute(tmap,[2 1 3]);
Y2 = Y2(end:-1:1,:,:);
%Y2 = Yb;
th = 1.95; % 2.3; %1.95; %1.95;
%Ov = 0.99*th*(T1s/max(T1s(:))-0.5);
mn = min(T1s(:));
mx = max(T1s(:));
Ov = 0.9*th*((T1s-mn)/mx-0.5)*2;
thf = 1.2*th;
Ov(Y2<-thf) = Y2(Y2<-thf);
Ov(Y2>thf) = Y2(Y2>thf);

djet = jet(2*64);
cool = djet(1:64,:);
cmap = [cool; gray(64); hot(64)];
clims = [min(Y2(:)) max(Y2(:))];
%Map in gray on main figure, since colormap applies to whole figure
% axes(handles.GLMresults);
A1 = [];
for i=1:param.nz
    A1 = [A1 squeeze(Ov(:,:,i))];
end
imagesc(A1,clims); colormap(gray);
axis off
axis image

h = figure;
clims = [min(Y2(:)) -min(Y2(:))];
for i=1:param.nz
    switch param.nz
        case 1
        case 2
            subplot(1,2,i);
        case 3
            subplot(1,3,i);
        case 4
            subplot(2,2,i);
        case {5,6}
            subplot(2,3,i);
        case {7,8,9}
            subplot(3,3,i);
        case {10,11,12}
            subplot(3,4,i);
        case {13,14,15}
            subplot(3,5,i);
        case 16
            subplot(4,4,i);
    end
    imagesc(squeeze(Ov(:,:,i)),clims);
    axis off; axis image;
    if i==1
        colorbar
    end
end;
colormap(cmap);

[~, name, ext] = fileparts(param.foldername);
fname = fullfile(output,[name ext '_GLM']);
print(h, '-dpng', [fname '.png'], '-r300');
saveas(h,fname,'fig')

%     close(h)



