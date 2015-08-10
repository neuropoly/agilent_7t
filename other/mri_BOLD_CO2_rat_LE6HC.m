function mri_BOLD_CO2_rat_LE6HC
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\LE6HC01';
scan = 'epip02';
pathNii = fullfile(path0,[scan '.nii']);
%load data
N = 660;
Nslice = 9;
T = 660; %11 minutes approximately
FOVx = 25; %field of view, in millimeters
FOVy = 25; %field of view, in millimeters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 1: Load the DICOM EPIP data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i0 = 1:N
    for s0 = 1:Nslice
        fname = fullfile(path0,[scan '.dcm'],['slice' gen_num_str(s0,3) 'image' gen_num_str(i0,3) 'echo001.dcm']);
        tY = dicomread(fname);
        if i0 == 1
            [nx ny] = size(tY);
            Y = zeros(nx,ny,Nslice,N);
        end
        Y(:,:,s0,i0) = tY;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 2: convert the DICOM data to NIFTI, to use in SPM8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Write nifti volumes
if ~exist(pathNii,'dir'), mkdir(pathNii); end
origin=[0 0 0];
voxel_size = [FOVx/64 FOVy/64 1];
datatype = 4;
description = 'Varian_data';
for i0 = 1:N
    fname = fullfile(pathNii,['volume' gen_num_str(i0,3) '.nii']);
    image = squeeze(Y(:,:,:,i0));
    ioi_write_nifti(image,voxel_size,origin,datatype,description,fname);    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 3: Construct T1 image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fnameAnat = fullfile(path0,'fsems04.nii','volume0001.nii'); 
V1 = spm_vol(fnameAnat);
Y1 = spm_read_vols(V1);
%
%Y1 = permute(Y1,[2 1 3]);
%Y1 = Y1(end:-1:1,:,:); %modify until the right orientation is obtained
VT1 = V1;
VT1.mat = zeros(4);
VT1.mat(1,1) = FOVx/256;
VT1.mat(2,2) = FOVy/256;
VT1.mat(3,3) = 1;
VT1.mat(4,4) = 1;
VT1.fname = 'T1.nii';
spm_write_vol(VT1,Y1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 4: average BOLD image
M = mean(Y,4);
%Plot average image on 3 x 3 subplot
figure; 
for i=1:Nslice 
    subplot(3,3,i); 
    %Double inversion for plot and axis xy 
    imagesc(squeeze(M(end:-1:1,end:-1:1,i)));
    %imagesc(squeeze(M(10:82,10:82,i)));  
    %imagesc(squeeze(Y(10:82,10:82,i,1)));  
    axis off; axis xy; 
end; 
colormap(gray);
%Step 5: construct stimulation protocol
lp = linspace(T/N,T,N);
%C0 = [1:90   121:210 241:330 361:450 481:570 601:660];
%C1 = [91:120 211:240 331:360 451:480 571:600];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 6: Use SPM8 to estimate the GLM -- see batch in the scripts folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
onsets = [90 210 330 450 570]; %duration: 30

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 7: Superpose t-stat on anatomical and zoom a bit to remove the ear!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T1
%V_T1 = spm_vol('T1_xy_permuted_x_inverted.nii'); 
V_T1 = spm_vol(fullfile(path0,'T1.nii')); 
T1 = spm_read_vols(V_T1);
%Tstat BOLD
%tstat = 'Stat_EPIP02_60s_duration';
tstat = 'Stat_EPIP02_realign';
Vb = spm_vol(fullfile(path0,tstat,'spmT_0001.img'));
Yb = spm_read_vols(Vb);
Yr = zeros(size(T1));
%resize:
for i0=1:Nslice
    Yr(:,:,Nslice+1-i0) = imresize(squeeze(Yb(end:-1:1,end:-1:1,i0)),4); 
end
%Select a subregion
ax = 1:256; %10:180; %vertical
ay = 1:256; %30:230; %horizontal
%ax = 1:256; ay = 1:256;
T1s = T1(ax,ay,:);
T1s = T1s(end:-1:1,end:-1:1,:);
Y2 = Yr(ax,ay,:);
th = 3.9; %1.95;
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
%clims = [-max(Y2(:)) max(Y2(:))];
clims = [min(Y2(:)) -min(Y2(:))];
for i=1:9  
    subplot(3,3,i); 
    %imagesc(squeeze(Yr(:,:,i)));
    imagesc(squeeze(Ov(:,:,i)),clims);  
    axis off; axis xy; 
    if i==1 
        colorbar
    end
end; 
colormap(cmap); 
