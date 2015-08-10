function [data,file_4dnii] = merge_3d_to_4d(list_3d_files,output)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if exist([list_3d_files{1} '.nii'],'file')
    for ii=1:length(list_3d_files)
        patate = aedes_read_nifti([list_3d_files{ii} '.nii']);
        data(:,:,:,ii) = patate.FTDATA;
    end
    [~,name,~] = fileparts(list_3d_files{1});
    file_4dnii = fullfile(output,['4d' name(1:3) '.nii']);
    disp(['Writing' file_4dnii])
    aedes_write_nifti(data,file_4dnii);
else
    data=0;
    file_4dnii='';
end
end

