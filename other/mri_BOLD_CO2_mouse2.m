function mri_BOLD_CO2_mouse2
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\WhiteMouseHC02\epip07.nii';
%load data
N = 87;
T = 5*60+53; %5 min 53 s
for i0 = 1:N
    fname = fullfile(path0,['volume' gen_num_str(i0,4) '.nii']);
    V = spm_vol(fname);
    tY = spm_read_vols(V);
    if i0 == 1
        [nx ny nz] = size(tY);
        Y = zeros(nx,ny,nz,N);
    end        
    Y(:,:,:,i0) = tY;
end
%average image
M = mean(Y,4);
%Plot average image on 3 x 3 subplot
figure; 
for i=1:9  
    subplot(3,3,i); 
    imagesc(squeeze(M(10:82,10:82,i)));  
    %imagesc(squeeze(Y(10:82,10:82,i,1)));  
    axis off; axis xy; 
end; 
colormap(gray);

lp = linspace(T/N,T,N);
C0 = [1:54 115:174 235:294]; %rest
C1 = [55:114 175:234 295:T]; %Hypercapnia
P0 = []; P1 = [];
%assign each image to a condition
for i=1:N
    [v0 I0] = min(abs(C0-lp(i)));
    [v1 I1] = min(abs(C1-lp(i)));
    if v0 < v1
        P0 = [P0 i];
    else
        P1 = [P1 i];
    end
end
%Average rest and hypercapnic images
Mr = mean(Y(:,:,:,P0),4);
Mh = mean(Y(:,:,:,P1),4);
Sr = std(Y(:,:,:,P0),[],4);
Sh = std(Y(:,:,:,P1),[],4);
Tr = Mr./Sr;
Th = Mh ./Sh;
Ta = (Mr-Mh)./(Sr .* Sh).^0.5;
Tt = Ta;
th = 1.95;
Tt(Ta<-th) = 0;
Tt(Ta>th) = 0;
%Difference:
%Df = Mr-Mh;
figure; 
for i=1:9  
    subplot(3,3,i); 
    imagesc(squeeze(Tt(10:82,10:82,i,1)),[-4 4]);  
    axis off; axis xy; 
end; 
colormap(gray);

Ms = 0.99*th*(M/max(M(:))-0.5)*0.5;
djet = jet(2*64);
cool = djet(1:64,:);
cmap = [cool; gray(64); hot(64)];
Ov = Ms;
Ov(Ta<-th) = Ta(Ta<-th);
Ov(Ta>th) = Ta(Ta>th);
figure; 
for i=1:9  
    subplot(3,3,i); 
    imagesc(squeeze(Ov(10:82,10:82,i,1)),[-2.7 2.7]);  
    axis off; axis xy; 
end; 
colormap(cmap);

%anatomical image
pathA = 'D:\Users\Philippe Pouliot\IRM_scans\WhiteMouseHC02\gems02.nii';
v1 = spm_vol(fullfile(pathA,'volume0001.nii'));
y1 = spm_read_vols(v1);
sc = 512/96;
x1 = round(sc*10);
x2 = round(sc*82);

Mr2 = imresize(Mr,sc);
Mh2 = imresize(Mh,sc);
Sr2 = imresize(Sr,sc);
Sh2 = imresize(Sh,sc);
Tr2 = Mr2./Sr2;
Th2 = Mh2 ./Sh2;
Ta2 = (Mr2-Mh2)./(Sr2 .* Sh2).^0.5;
Tt2 = Ta2;
th = 1.95;
Tt2(Ta2<-th) = 0;
Tt2(Ta2>th) = 0;
%OV = imresize(Ov(:,:,7,1),sc);
M2 = imresize(M,sc);
Ms2 = 0.99*th*(M2/max(M2(:))-0.5)*0.5;
Ov2 = Ms2;
Ov2(Ta2<-th) = Ta2(Ta2<-th);
Ov2(Ta2>th) = Ta2(Ta2>th);
OV = Ov2(:,:,7,1);
%Shift OV
OV = [zeros(25,512);OV(1:512-25,:)];
Ou = squeeze(y1(:,:,4));
Ou = 0.99*th*(Ou/max(Ou(:))-0.5)*0.5;
Ou(OV<-th) = OV(OV<-th);
Ou(OV>th) = OV(OV>th);
figure; imagesc(Ou(x1:x2,x1:x2),[-2.7 2.7]); axis off; axis xy; colormap(cmap)
% 
% figure; imagesc(squeeze(Y(:,:,1)));
% figure; imagesc(squeeze(Y(:,16,:)));
% figure; imagesc(squeeze(Y(26,:,:)));
% x = squeeze(mean(mean(Y(25:27,15:17,:),1),2));
% x0 = linspace(0,15.75,100);
% figure; plot(x0,x,'k'); hold on
% ylabel('BOLD signal, average over 9 voxels')
% xlabel('Time (minutes)')
% title('Mouse, alternating rest and hypercapnia (lines above)')
% z0 = 2:2:16; %[0 2 4 6 8 10 12 14];
% %z1 = [1 3 5 7
% for i1=1:length(z0)
%     v = (z0(i1)-1):z0(i1);
%     plot(v,repmat(9.7*1e5,length(v)),'k'); hold on
% end
% %x = x-mean(x);
% f = fft(x);
% f = abs(f);
% figure; plot(f)
% a=1;
