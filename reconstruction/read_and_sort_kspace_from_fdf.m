function [data_fdf,param] = read_and_sort_kspace_from_fdf(fid_file,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Read with aedes
[pathstr, name, ext] = fileparts(fid_file);
fdf_folder= [pathstr filesep name '.img'];
disp(['Reading .fdf files from ' fdf_folder ' with aedes'])
fdf_files=dir([fdf_folder '/s*.fdf']);
input={fdf_files(:).name};
if iscell(input)
    nb_files = size(input,2);
else
    nb_files = 1;
end

for k = 1:nb_files
    if nb_files == 1
        input_file = fullfile(fdf_folder,input{1});
    else
        input_file = fullfile(fdf_folder,input{k});
    end
    patate = aedes_readfdf(input_file);
    data_fdf(:,:,k) = patate.FTDATA;
end

param.nx = size(data_fdf,1);
param.ny = size(data_fdf,2);
param.nz = str2num(input_file(regexp(input_file,'slice')+5:regexp(input_file,'slice')+7));
param.nt = str2num(input_file(regexp(input_file,'image')+5:regexp(input_file,'image')+7));

%% Reshape
try
    data_fdf=reshape(data_fdf,param.nx,param.ny,param.nt,param.nz);
    data_fdf=permute(data_fdf,[1 2 4 3]);
%     data_fdf=data_fdf(param.nx:-1:1,param.ny:-1:1,:,:);
catch
    data_fdf=data_fdf;
end

%% Save in .nii
% if param.save_nii
%     output_dir=[pathstr filesep name '_recon.nii' filesep];
%     if ~exist(output_dir,'dir')
%         mkdir(output_dir);
%     end
%     output_file_rs=[output_dir 'rs_xcorr_type' num2str(param.correction) '.nii'];
%     try
%         disp(['Writing ' output_file_rs])
%         aedes_write_nifti(data_fdf,output_file_rs);
%     catch exception
%         errordlg(['unable to write ' output_file_rs])
%     end
% end
% disp('done')

end

