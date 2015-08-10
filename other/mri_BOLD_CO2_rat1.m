function mri_BOLD_CO2_rat1
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\LE5HC4ch201\epip01.dcm';
path1 = 'D:\Users\Philippe Pouliot\IRM_scans\LE5HC4ch201\epip01.nii';
%load data
N = 600;
Sl = 9;
%nx = 64; ny = 64;
T = 24*60+45; %24 min 45 s approximately
for i0 = 1:N
    for s0 = 1:Sl
        fname = fullfile(path0,['slice' gen_num_str(s0,3) 'image' gen_num_str(i0,3) 'echo001.dcm']);
        tY = dicomread(fname);
        if i0 == 1
            [nx ny] = size(tY);
            Y = zeros(nx,ny,Sl,N);
        end
        Y(:,:,s0,i0) = tY;
    end
end
%Write nifti volumes
if ~exist(path1,'dir'), mkdir(path1); end
origin=[0 0 0];
voxel_size = [40/64 40/64 1];
datatype = 4;
description = 'Varian_data';
for i0 = 1:N
    fname = fullfile(path1,['volume' gen_num_str(i0,3) '.nii']);
    image = squeeze(Y(:,:,:,i0));
    ioi_write_nifti(image,voxel_size,origin,datatype,description,fname);    
end

%Construct T1 image
fnameAnat = fullfile('D:\Users\Philippe Pouliot\IRM_scans\LE5HC4ch201\fsems04.nii','volume0001.nii'); 
V1 = spm_vol(fnameAnat);
Y1 = spm_read_vols(V1);
%
Y1 = permute(Y1,[2 1 3]);
Y1 = Y1(end:-1:1,:,:);
VT1 = V1;
VT1.mat = zeros(4);
VT1.mat(1,1) = 40/256;
VT1.mat(2,2) = 40/256;
VT1.mat(3,3) = 1;
VT1.mat(4,4) = 1;
VT1.fname = 'T1.nii';
spm_write_vol(VT1,Y1);
%average image
M = mean(Y,4);
%Plot average image on 3 x 3 subplot
figure; 
for i=1:Sl 
    subplot(3,3,i); 
    imagesc(squeeze(M(end:-1:1,end:-1:1,i)));
    %imagesc(squeeze(M(10:82,10:82,i)));  
    %imagesc(squeeze(Y(10:82,10:82,i,1)));  
    axis off; axis xy; 
end; 
colormap(gray);

%ons = [66 186 306 426 546 666 786 906 1026 1146 1266 1386]; %Hypercapnia

lp = linspace(T/N,T,N);
%C0 = [1:60 121:180 241:300 361:420 481:540 601:660 721:780 841:900 961:1020 1081:1140 1201:1260 1321:1380 1441:T]; %rest
%C1 = [61:120 181:240 301:360 421:480 541:600 661:720 781:840 901:960 1021:1080 1141:1200 1261:1320 1381:1440]; %Hypercapnia

C0 = [6:60 126:180 246:300 366:420 486:540 606:660 726:780 846:900 966:1020 1086:1140 1206:1260 1326:1380 1446:T]; %rest
C1 = [66:120 186:240 306:360 426:480 546:600 666:720 786:840 906:960 1026:1080 1146:1200 1266:1320 1386:1440]; %Hypercapnia
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
%Tr = Mr./Sr;
%Th = Mh ./Sh;
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
    imagesc(squeeze(Tt(end:-1:1,end:-1:1,i,1)));  
    axis off; axis xy; 
end; 
colormap(gray);


%%%%%%%%%%%%%%%%%
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



