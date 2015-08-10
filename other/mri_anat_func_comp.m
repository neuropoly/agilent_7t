%% Compares the anatomical and fonctionnal images
A.file = '/Volumes/hd2_local/users_local/jfpp/data/xp_2014/s_20140117_Test_bold_souris01/fsems_02.nii/volume1.nii.gz';
[A.img A.dims A.scales A.bpp A.endian] = read_avw(A.file);

F.file = '/Volumes/hd2_local/users_local/jfpp/data/xp_2014/s_20140117_Test_bold_souris01/epip_0.5iso01.nii/srv4d.nii.gz';
[F.img F.dims F.scales F.bpp F.endian] = read_avw(F.file);
Fmean = mean(F.img,4);
Fmean=imresize(Fmean,[A.dims(1) A.dims(2)]);

[pathfile,~,~] = fileparts(F.file); 
Fmeanfile = fullfile(pathfile,'meansrv4d');
save_avw(Fmean,Fmeanfile,'s',A.scales);

A.img = A.img/max(max(max(max(A.img))));
Fmean = Fmean/max(max(max(max(Fmean))));
diff = A.img-Fmean;

close all
figure('Name','Anat')
for i=1:A.dims(3)
    subplot(A.dims(3)/3,3,i)
    imagesc(A.img(:,:,i))
    xlabel(['slice #' num2str(i)])
end
colormap gray

figure('Name','Epip')
for i=1:F.dims(3)
    subplot(A.dims(3)/3,3,i)
    imagesc(Fmean(:,:,i))
    xlabel(['slice #' num2str(i)])
end
colormap gray

figure('Name','Superpose')
for i=1:F.dims(3)
    subplot(A.dims(3)/3,3,i)
    imagesc(A.img(:,:,i))
    hold on
    imagesc(Fmean(:,:,i))
    xlabel(['slice #' num2str(i)])
end
hold off
colormap gray
 
figure('Name','Difference')
for i=1:F.dims(3)
    subplot(A.dims(3)/3,3,i)
    imagesc(diff(:,:,i))
    xlabel(['slice #' num2str(i)])
end
colormap gray


