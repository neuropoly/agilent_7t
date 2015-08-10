function [tsnr3d] = mri_bold_compute_tsnr(fname_data,opt)
% =========================================================================
% Compute TSNR of DW data. Uses FSL tools.
% 
% 
% INPUT
% fname_data		string. No need to put the extension.
% (opt)
%   moco			0 | 1*	 moco using FLIRT.
%   detrend			0 | 1*   detrend data.
%   fname_tsnr		string.  file name tsnr
%   fname_log		string.  log for processing.
%
% OUTPUT
% tsnr3d            matrix containing 3d tsnr map
%
% Example:   bold_compute_tsnr('diff','tw_SNR_Ydir_5nav.txt')
% 
% Jean François Pelletier Paquette <jfpp23@gmail.com>
% 2014-01-23
% =========================================================================

if nargin<1, help mri_bold_compute_tsnr, return, end
if ~exist('opt'), opt = []; end
if isfield(opt,'moco'), moco_do = opt.moco; else moco_do = 1; end
if isfield(opt,'detrend'), detrend_do = opt.detrend; else detrend_do = 1; end
if isfield(opt,'fname_tsnr'), fname_tsnr = opt.fname_tsnr; else fname_tsnr = 'tsnr'; end
if isfield(opt,'fname_log'), fname_log = opt.fname_log; else fname_log = 'log_bold_compute_tsnr.txt'; end
if isfield(opt,'display'), display_do = opt.display; else display_do = 1; end

% delete log file
if exist(fname_log), delete(fname_log), end

j_disp(fname_log,['\n\n\n=========================================================================================================='])
j_disp(fname_log,['   Running: mri_bold_compute_tsnr.m'])
j_disp(fname_log,['=========================================================================================================='])
j_disp(fname_log,['.. Started: ',datestr(now)])

% Check parameters
j_disp(fname_log,['\nCheck parameters:'])
j_disp(fname_log,['.. Input data:            ',fname_data])
j_disp(fname_log,['.. moco_do:               ',num2str(moco_do)])
j_disp(fname_log,['.. detrend_do:            ',num2str(detrend_do)])
j_disp(fname_log,['.. fname_tsnr:            ',fname_tsnr])
j_disp(fname_log,['.. fname_log:             ',fname_log])

% Convert data to 1 4D nifti file
[~,dims,~,~,~] = read_avw(fname_data);
if dims(4)==1
    [filepath,name,ext] = fileparts(fname_data);
    cd(filepath)
    prefix = name(1:regexp(name,'vol'));
    fourdfile=[prefix '4d.nii.gz'];
    if exist(fourdfile,'file')==0
        j_disp(fname_log,['\nCreate the 4d nifti file: ' fourdfile])
        cmd = ['fslmerge -t ',fourdfile,' ', prefix, '*'];
        [status result] = unix(cmd); if status, error(result); end
    else
        j_disp(fname_log,['\n4d nifti file ' fourdfile ' already exists'])
    end
    file_name=fullfile(filepath,fourdfile);
else
    [filepath,name,ext] = fileparts(fname_data);
    prefix = name(1:regexp(name,'vol'));
    file_name=fname_data
end
if moco_do
	% Motion correction
	j_disp(fname_log,['\nMotion correction...'])
    moco_file = fullfile(filepath,'tmp.bold_moco');
	cmd = ['mcflirt -in ',file_name,' -out ' moco_file ' -sinc_final -dof 6'];
	j_disp(fname_log,['>> ',cmd]); [status result] = unix(cmd); if status, error(result); end
	j_disp(fname_log,['.. File created: tmp.bold_moco'])
	% update file name
	file_name = moco_file;
end

% Open NIFTI file
j_disp(fname_log,['\nOpen BOLD images...'])
[data,dims,scales,bpp,endian] = read_avw(file_name);
[nx ny nz nt] = size(data);

% reshape
data2d = reshape(data,nx*ny*nz,nt);
clear data

% compute TSNR
j_disp(fname_log,['\nCompute TSNR...'])
tsnr = zeros(1,nx*ny*nz);
nb_voxels = nx*ny*nz;
i_progress = 0;
pourcentage = 10;
for i_vox = 1:nb_voxels

	data1d = data2d(i_vox,:);

	% detrend data
	if detrend_do
		 data1d = detrend(data1d,'linear') + mean(data1d);
	end 
		
	% compute TSNR
	tsnr(i_vox) = mean(data1d) / std(data1d);
    
	% display progress
	if i_progress > nb_voxels/10;
		j_disp(fname_log,['.. ',num2str(pourcentage),'/100'])
		pourcentage = pourcentage + 10;
		i_progress = 0;
	else
		i_progress = i_progress+1;
	end
end

% Write TSNR
j_disp(fname_log,['\n\nWrite TSNR...'])
tsnr3d = reshape(tsnr,nx,ny,nz);
fname_tsnr=[prefix fname_tsnr];
save_avw(tsnr3d,fname_tsnr,'s',scales);
j_disp(fname_log,['.. File created: ',fname_tsnr])

% Copy geometry information
j_disp(fname_log,['\nCopy geometry information...'])
cmd = ['fslcpgeom ',fname_data,' ',fname_tsnr];
j_disp(fname_log,['>> ',cmd]); [status result] = unix(cmd); if status, error(result); end

% Display TSNR
if display_do
    figure('Name','tSNR map')
    for i=1:nz
        subplot(3,round(nz/3),i);
        imagesc(tsnr3d(2:end-1,2:end-1,i)); xlabel(['slice #' num2str(i)])
        if i==nz
            colorbar
        end
    end
%     for i=1:nz
%         figure(i+1)
%         imagesc(tsnr3d(:,:,i));
%     end
end

% Remove temporary files
j_disp(fname_log,['\nRemove temporary files...'])
delete 'tmp.*'

% display time
j_disp(fname_log,['\n.. Ended: ',datestr(now)])
j_disp(fname_log,['=========================================================================================================='])
j_disp(fname_log,['\n'])






