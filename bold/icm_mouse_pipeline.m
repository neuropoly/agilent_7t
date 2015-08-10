function [rspace_sr,tmap,raw_quality_stats,pp_quality_stats,param,output] = icm_mouse_pipeline(input,output,param)
% Pipeline to process 1 mouse BOLD experiment
% Steps:
% 1) Load data
%   a) icm_fid_recon: reads .fid file and does the reconstruction of the rspace
%       data.
%   OR
%   b) read_and_sort_kspace_from_fdf: reads the .fdf files from varian.
%   OR
%   c) aedes_read_nifti: reads the 4D .nii from a previous recon
%
% 2) Evaluate BOLD quality
%   evaluate_BOLD_quality: evaluates the global quality of the images.
%   Computes tspr, tsnr, 3d average...
%
% 3) Preprocessing steps
%   a) realign and smooth
%   b) high pass filter
%   c) register to anatomical
%   d) register to template
%
% 4) Run GLM
%   icm_spm_analysis: designs the experiment and runs the GLM from SPM8 to
%   produce the statistical parametric maps for the experiment.

%% Step 0: input verification
switch nargin
    case 0
        error('need input folder')
    case 1
        output=[input filesep 'test'];
        param=[];
    case 2
        param=[];
    case 3
end

%% Step 1: Load data
close all
param.foldername=input;
if strcmp(input(end-2:end),'fid')
    [patate,~,patate2] = icm_fid_recon(input,6,param);
    rspace = abs(patate{1}.xcorr6);
    param=patate2{1};
%     rspace = patate{1}.pointwise;
%     rspace = patate{1}.tripleref;
elseif strcmp(input(end-2:end),'img')
    [rspace,param] = read_and_sort_kspace_from_fdf(input,param);
elseif strcmp(input(end-2:end),'nii')
    patate = aedes_read_nifti(input);
    rspace = patate.FTDATA;
    [param.nx,param.ny,param.nz,param.nt] = size(rspace);
else
    error('file not found')
end

%% Step 2: evaluate BOLD quality
if ~exist(output,'file')
    mkdir(output);
end
disp('evaluating BOLD quality')
[raw_quality_stats] = evaluate_BOLD_quality(rspace,output);

save_bold_quality_stats(raw_quality_stats,output,param,'raw');

% Save in 3D nifti
disp('Writing 3D nifti')
for ii=1:param.nt
    files_nii{ii} = fullfile(output,['volume' gen_num_str(ii,3)]);
    files_rnii{ii} = fullfile(output,['rvolume' gen_num_str(ii,3)]);
    files_snii{ii} = fullfile(output,['svolume' gen_num_str(ii,3)]);
    files_srnii{ii} = fullfile(output,['srvolume' gen_num_str(ii,3)]);
    aedes_write_nifti(rspace(:,:,:,ii),files_nii{ii});
end

%% Step 3: Preprocessing steps
spm_jobman('initcfg');
disp('preprocessing')

field_names={'realign','smooth','drift_correction'};
default_values=[1 1 1];
field_verif = isfield(param,field_names);
if sum(field_verif)<length(default_values)
    default_fields = find(field_verif==0);
    for j=default_fields
        param.(field_names{j})=default_values(j);
    end
end

if ~isfield(param,'realign'), param.realign = 1; end
if ~isfield(param,'smooth'), param.smooth = 1; end
try
    if param.realign && param.smooth
        realign_smooth_BOLD(output,param)
        param.files_to_analyse = files_srnii;
    elseif param.realign
        realign_BOLD(output,param)
        param.files_to_analyse = files_rnii;
    elseif param.smooth
        smooth_BOLD(output,param)
        param.files_to_analyse = files_snii;
    else
        param.files_to_analyse = files_nii;
    end
catch
    disp('failed to preprocess the data')
	param.files_to_analyse = files_nii;
end

% Merge and load preprocessed data for evaluation
disp('reloading preprocessed data')
[rspace,param.file_4d] = merge_3d_to_4d(files_nii,output);
[rspace_r,param.file_r4d] = merge_3d_to_4d(files_rnii,output);
[rspace_s,param.file_s4d] = merge_3d_to_4d(files_snii,output);
[rspace_sr,param.file_rs4d] = merge_3d_to_4d(files_srnii,output);

% if param.drift_correction
%     % Motion correction
%     cmd = ['mcflirt -in ',param.file_rs4d,' -out tmp.bold_moco -sinc_final -dof 6'];
%     [status,result] = unix(cmd); if status, error(result); end
% end
    
if param.realign && param.smooth
    [pp_quality_stats] = evaluate_BOLD_quality(rspace_sr,output);
elseif param.realign
    [pp_quality_stats] = evaluate_BOLD_quality(rspace_r,output);
elseif param.smooth
    [pp_quality_stats] = evaluate_BOLD_quality(rspace_s,output);
else
    [pp_quality_stats] = evaluate_BOLD_quality(rspace,output);
end
save_bold_quality_stats(pp_quality_stats,output,param,'pp');

%% Step 4: Run GLM
spm_jobman('initcfg');
disp('processing GLM')
try
    param = icm_spm_mouse(output,param);
    Vb = spm_vol(fullfile(param.pathStat,'spmT_0001.img'));
    tmap = spm_read_vols(Vb);
    glm_epi_display(rspace_sr,tmap,output,param)
catch
    disp('error processing GLM')
end

output_matlab = [output filesep 'analysis.mat'];
save(output_matlab)

end

