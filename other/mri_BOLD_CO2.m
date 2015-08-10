function mri_BOLD_CO2
%path0 = 'D:\Users\Philippe Pouliot\IRM_scans\BOLD_CO2epip03.nii';
path0 = fullfile(filesep,'Volumes','hd2_local','users_local','jfpp','data','hypercapnia');
%load data
N = 100;
for i0 = 1:N
    fname = fullfile(path0,['volume' gen_num_str(i0,4) '.nii']);
    V = spm_vol(fname);
    tY = spm_read_vols(V);
    if i0 == 1
        [nx ny] = size(tY);
        Y = zeros(nx,ny,N);
    end        
    Y(:,:,i0) = tY;
end
figure; imagesc(squeeze(Y(:,:,1)));
figure; imagesc(squeeze(Y(:,16,:)));
figure; imagesc(squeeze(Y(26,:,:)));
x = squeeze(mean(mean(Y(25:27,15:17,:),1),2));
x0 = linspace(0,15.75,100);
figure; plot(x0,x,'k'); hold on
ylabel('BOLD signal, average over 9 voxels')
xlabel('Time (minutes)')
title('Mouse, alternating rest and hypercapnia (lines above)')
z0 = 2:2:16; %[0 2 4 6 8 10 12 14];
%z1 = [1 3 5 7
for i1=1:length(z0)
    v = (z0(i1)-1):z0(i1);
    plot(v,repmat(9.7*1e5,length(v)),'k'); hold on
end
%x = x-mean(x);
f = fft(x);
f = abs(f);
figure; plot(f)
a=1;
