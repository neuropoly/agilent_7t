function [rspace,kspace,param] = icm_fid_recon(input_folders,correction,param)
%%
% This function reads the .fdf and .fid files and performs the
% reconstruction(s) of the raw kspace.

% input_folders which can be one of the 3 following:
% Case 1: input_folders is a string containing the folder of a single .fid file
% Case 2: input_folders is a cell containing multiple folders of single
% .fid file
% Case 3: input_folders is a string containing the folder of an experiment
% with multiple .fid files

% correction can range from 0 to 8 which correspond to multiple different
% reconstruction algorithm for the cross correlation reconstruction.
% correction can be a vector to compute different reconstruction.
% (kspace_reading_xcorr)
% 0: no correction
% 1: Correct odd and even echoes mismatch with the central columns of each scan using cross correlation of multiple central columns
% 2: Correct odd and even echoes mismatch with the 2 most correlated odd/even columns of each scan using cross correlation
% 3: Correct odd and even echoes mismatch individually for each column
% 4: Odd and even echoes mismatch correction using the cross correlation on the reference scans
% 5: Global phase correction with linear interpolation on the reference scans
% 6: Odd and even correction mismatch (4) + global phase correction with linear interpolation using the reference scans (5)
% 9: Global phase correction with linear interpolation using the average kspace
% 10: Individual global phase correction with linear interpolation on each scan (very long)
%
% The pointwise and tripleref reconstruction are also done and the .fdf
% files are also extracted

%% input_folders interpretation
if nargin == 1
    correction = 6;     %correction to use by default
end
if ischar(input_folders)
    if strcmp(input_folders(end-2:end),'fid')   % Case 1
        nb_folders = 1;
        epip_folders{1} = input_folders;
    else                                        % Case 3
        eliminate_dot_underscore(input_folders);
        xp_list = dir([input_folders filesep '*.fid']);
        nb_folders=0;
        for i=1:length(xp_list)
            fid_folders{i} = xp_list(i).name;
            if length(fid_folders{i})>=4
                if strcmp(fid_folders{i}(1:4),'epip') && strcmp(fid_folders{i}(end-2:end),'fid')
                    nb_folders = nb_folders+1;
                    epip_folders{nb_folders} = [input_folders filesep fid_folders{i}];
                end
            end
        end
    end
elseif iscell(input_folders)                    % Case 2
    nb_folders = length(input_folders);
    epip_folders{1} = input_folders;
else
    error('input must be 1 of the 3 accepted cases')
end
if nb_folders==0
    error('No folder found')
end
nb_correction = length(correction);

%% Parameter verification
field_names={'data','save_nii','center_kspace','center_rspace','display','median_smoothing',...
    'navigator','correction','vol_pour','fourier2D','outputphase','negative_image','kspace_filtering'};
default_values=[0 1 0 2 0 0 ...
    1 0 1 0 0 0 1];
for i=1:nb_folders
    param{i}.foldername=epip_folders{i};
    if ~exist(epip_folders{i},'file')
        errordlg('Cannot find the epip_folders')
    end
    field_verif = isfield(param{i},field_names);
    if sum(field_verif)<length(default_values)
        default_fields = find(field_verif==0);
        for j=default_fields
            param{i}.(field_names{j})=default_values(j);
        end
    end
end

%% Load fdf files
for i=1:nb_folders
    [rspace{i}.datafdf,param{i}] = read_and_sort_rspace_from_fdf(epip_folders{i},param{i});
end
disp('Done reading fdf')

%% Load fid files
for i=1:nb_folders
    [kspace{i}.datafdf,param{i}] = read_and_sort_kspace_from_fid(epip_folders{i},param{i});
    if param{i}.kspace_filtering
        disp('Doing kspace median filtering')
        kspace{i}.datafdf.Rplus = kspace_median_filtering(kspace{i}.datafdf.Rplus);
        kspace{i}.datafdf.Rminus = kspace_median_filtering(kspace{i}.datafdf.Rminus);
        kspace{i}.datafdf.Eplus = kspace_median_filtering(kspace{i}.datafdf.Eplus);
        kspace{i}.datafdf.Eminus = kspace_median_filtering(kspace{i}.datafdf.Eminus);        
    end
end
disp('Done reading fid')

%% xcorr_reconstruction
for i=1:nb_folders
    for j=1:nb_correction
        [pathstr,name,~] = fileparts(epip_folders{i});
        output_dir{i}=[pathstr filesep name '_recon.nii' filesep];
        output_file_rs=[output_dir{i} 'rs_xcorr_type' num2str(param{i}.correction) '.nii'];
        param{i}.correction=correction(j);
%         if ~exist(output_file_rs,'file')
            [kspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                ksN_xcorr{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                rspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                rsN_xcorr{i}.(genvarname(['xcorr' num2str(param{i}.correction)]))] = ...
                kspace_reading_xcorr(kspace{i}.datafdf,epip_folders{i},param{i});
            if param{i}.center_rspace==2
                [kspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                    rspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)]))] =...
                    rspace_centering(kspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                    rspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])),...
                    rspace{i}.datafdf,param{i});
            end
%         else
%             patate = aedes_read_nifti(output_file_rs);
%             rspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])) = patate.FTDATA;
%             kspace{i}.(genvarname(['xcorr' num2str(param{i}.correction)])) = 0;
%             ksN_xcorr{i}.(genvarname(['xcorr' num2str(param{i}.correction)])) = 0;
%             rsN_xcorr{i}.(genvarname(['xcorr' num2str(param{i}.correction)])) = 0;
%         end
    end
end
%% Varian reconstructions
for i=1:nb_folders
    output_file=[output_dir{i} 'pointwise.nii'];
    if ~exist(output_file,'file')
        [kspace{i}.pointwise,rspace{i}.pointwise] = kspace_reading_pointwise(kspace{i}.datafdf,epip_folders{i},param{i});
        if param{i}.center_rspace==2
            [kspace{i}.pointwise,rspace{i}.pointwise] =...
                rspace_centering(kspace{i}.pointwise,rspace{i}.pointwise,rspace{i}.datafdf,param{i});
        end
    else
        patate = aedes_read_nifti(output_file);
        rspace{i}.pointwise = patate.FTDATA;
        kspace{i}.pointwise = 0;
        ksN_xcorr{i}.pointwise = 0;
        rsN_xcorr{i}.pointwise = 0;
    end
end

for i=1:nb_folders
    output_file=[output_dir{i} 'pointwise.nii'];
    if ~exist(output_file,'file')
        
        [kspace{i}.tripleref,rspace{i}.tripleref] = kspace_reading_tripleref(kspace{i}.datafdf,epip_folders{i},param{i});
        if param{i}.center_rspace==2
            [kspace{i}.tripleref,rspace{i}.tripleref] =...
                rspace_centering(kspace{i}.tripleref,rspace{i}.tripleref,rspace{i}.datafdf,param{i});
        end
    else
        patate = aedes_read_nifti(output_file);
        rspace{i}.tripleref = patate.FTDATA;
        kspace{i}.tripleref = 0;
        ksN_xcorr{i}.tripleref = 0;
        rsN_xcorr{i}.tripleref = 0;
    end
end

%% Save in .mat
if ischar(input_folders)
    output_mat_file = fullfile(input_folders,['recon_' date '.mat']);
    disp(['Writing ' output_mat_file])
    save(output_mat_file,'rspace','kspace','param','-v7.3');
    disp('done')
else
    for ii=1:nb_folders
        output_mat_file = fullfile(input_folders{ii},['recon_' date '.mat']);
        disp(['Writing ' output_mat_file])
        save(output_mat_file,'rspace','kspace','param','-v7.3');
        disp('done')
    end
end

