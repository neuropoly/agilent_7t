%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Superpose t-stat on anatomical and zoom a bit to remove the ear!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T1
V_T1 = spm_vol('T1_xy_permuted_x_inverted.nii'); 
T1 = spm_read_vols(V_T1);
%Tstat BOLD
V = spm_vol('spmT_0001.img');
Y = spm_read_vols(V);
Yr = zeros(size(T1));
%resize:
for i0=1:9
    Yr(:,:,i0) = imresize(squeeze(Y(:,:,i0)),4); 
end
%Select a subregion
ax = 10:180; %vertical
ay = 30:230; %horizontal
%ax = 1:256; ay = 1:256;
T1s = T1(ax,ay,:);
Y2 = Yr(ax,ay,:);
th = 8; %1.95;
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
figure; 
clims = [min(Y2(:)) max(Y2(:))];
for i=1:9  
    subplot(3,3,i); 
    imagesc(squeeze(Ov(end:-1:1,:,i)),clims);  
    %imagesc(squeeze(Yr(end:-1:1,:,i)));  
    axis off; axis xy;  
end; 
colormap(cmap); colorbar

