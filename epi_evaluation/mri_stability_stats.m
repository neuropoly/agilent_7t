function [stats] = mri_stability_stats(fname_data,opt)
% =========================================================================
% Compute min/mean, max/mean, drift, spatial and temporal distribution of
% epip data and tSNR map
% 
% 
% INPUT
% fname_data		string. No need to put the extension. path to the file
% containing the nifti data.
% (opt)
%   display			0 | 1*	display the results
%   save_average    0 | 1*  save the averaged image in nifti
% OUTPUT
% stats             Contains all the computed data
% 
% Jean François Pelletier Paquette <jfpp23@gmail.com>
% 2014-01-20
% =========================================================================

if nargin<1, help mri_bold_compute_tsnr, return, end
if ~exist('opt','var'), opt = []; end
if isfield(opt,'display'), display_do = opt.display; else display_do = 0; end
if isfield(opt,'save_average'), save_do = opt.save_average; else save_do = 0; end
if isfield(opt,'use_mask'), mask_do = opt.use_mask; else mask_do = 1; end
if isfield(opt,'use_all'), all_do = opt.use_all; else all_do = 1; end

% Open NIFTI file
if ischar(fname_data)
    [data,dims,scales,bpp,endian] = read_avw(fname_data);
else
    data = fname_data;
end
[nx ny nz nt] = size(data);

% Compute tSNR
% tsnr_opt.moco = 0;
% tsnr_opt.detrend = 0;
% tsnr3d = mri_bold_compute_tsnr(fname_data,tsnr_opt);

% Compute mean, max, min, drift
mean_voxel = mean(data,4);

% Save the averaged data
if save_do
    save_avw(mean_voxel,'mean_volume','s',scales);
end

global_mean = mean(mean(mean(mean(data,1),2),3),4);
stats.mask = mean_voxel>global_mean;
stats.mask = repmat(stats.mask,[1 1 1 nt]);
masked_data = data.*stats.mask;
if save_do
    save_avw(masked_data,'mask','s',scales);
end
mean_voxel = mean(masked_data,4);
if mask_do
    raw_data=data;
    data=masked_data;
    clear masked_data
end

stats.max_voxel = max(data,[],4)./mean_voxel;
stats.min_voxel = min(data,[],4)./mean_voxel;

% Compute drift
stats.drift_voxel = (data(:,:,:,end)-data(:,:,:,1))./mean_voxel;

% Select ROI and compute temporal and spatial signal
if all_do
    temporal_signal = squeeze(mean(mean(mean(data,1),2),3));
    spatial_signal = mean(data(data>0),4);
else
    stats.xROI = nx/4:3*nx/4;
    stats.yROI = ny/4:3*ny/4;
    stats.zROI = 1:nz;
    temporal_signal = squeeze(mean(mean(mean(data(stats.xROI,stats.yROI,stats.zROI,:),1),2),3));
    spatial_signal = mean(data(stats.xROI,stats.yROI,stats.zROI,:),4);
end
mean_temporal = mean(temporal_signal);
stats.temporal_signal = temporal_signal;
% stats.temporal_signal = temporal_signal./mean_temporal;
mean_spatial = mean(mean(mean(spatial_signal,1),2),3);
stats.spatial_signal = spatial_signal./mean_spatial;

% Compute difference between last and first image
stats.motion = raw_data(:,:,:,end)-raw_data(:,:,:,1);

if display_do
    figure('Name','Max voxel value / mean voxel')
    for i=1:nz
        subplot(3,round(nz/3),i);
        imagesc(stats.max_voxel(:,:,i)); xlabel(['slice #' num2str(i)])
        if i==nz
            colorbar
        end
    end
    figure('Name','Min voxel value / mean voxel')
    for i=1:nz
        subplot(3,round(nz/3),i);
        imagesc(stats.min_voxel(:,:,i)); xlabel(['slice #' num2str(i)])
        if i==nz
            colorbar
        end
    end
    figure('Name','Drift')
    for i=1:nz
        subplot(3,round(nz/3),i);
        imagesc(stats.drift_voxel(:,:,i)); xlabel(['slice #' num2str(i)])
        if i==nz
            colorbar
        end
    end
    figure ('Name','temporal signal')
    plot(stats.temporal_signal)
    figure ('Name','spatial distribution')
    hist(stats.spatial_signal(:))
    figure ('name','difference between 1st and last image')
    for i=1:nz
        subplot(3,round(nz/3),i);
        imagesc(stats.motion(:,:,i)); xlabel(['slice #' num2str(i)])
        if i==nz
            colorbar
        end
    end
end

end

