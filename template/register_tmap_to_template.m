function [] = register_tmap_to_template(input,output,param)
% Syntax: Register_tmap_to_template(input,output,param)
% 
% Input: structure containing 2 to 3 string. 
%   Input.tmap contains the string refering to the tmap of the subject
%   (.mat)
%   Input.affine contains the string refering to the affine transformation
%   file (.txt or .mat)
%   Input.warp contains the string refering to the warp transformation
%   (.nii)
%
% Output: contains the string with the file name where the transformed tmap
% should be stored (.mat)
%
% Param:
%   Param.affine = 1 by default. Means the affine transformation should be
%   applied
%   Param.warp = 1 by default. Means the warping field should be applied

% Load the tmap
spm_file = open(input.tmap);
tmap_fullfile = fullfile(spm_file.SPM.swd,spm_file.SPM.xCon(1,1).Vspm.fname);
[tmap_dirfile tmap_filefile tmap_extfile] = fileparts(tmap_fullfile);
V1 = spm_vol(tmap_fullfile);
tmap = spm_read_vols(V1);

% Load the template
template = load_untouch_nii(input.template);
tmap_temp_sr = size(template.img)./size(tmap).*100; %tmap to template size ratio

% Transform the tmap into a nifti file
cmd = ['fslchfiletype_exe NIFTI ' tmap_fullfile];
unix(cmd)
tmap_fullfile = fullfile(tmap_dirfile,[tmap_filefile '.nii']);
cmd = ['mv ' tmap_fullfile ' ' output.nifti_tmap];
unix(cmd)

%Resample the image to the template size
if tmap_temp_sr(1)~=100 || tmap_temp_sr(2)~=100 || tmap_temp_sr(3)~=100
    cmd = ['c3d ' output.nifti_tmap ' -resample ' num2str(tmap_temp_sr(1)) '%x' num2str(tmap_temp_sr(2)) '%x' num2str(tmap_temp_sr(3)) '% -o ' output.nifti_tmap];
    unix(cmd)
end

% Apply the affine transformation
if param.affine
    cmd = ['WarpImageMultiTransform 3 ' output.nifti_tmap ' ' output.nifti_rtmap ' -R ' input.template ' --use-BSpline ' input.affine];
    unix(cmd)
end

% Apply the warping field
if param.warp
    cmd = ['WarpImageMultiTransform 3 ' output.nifti_rtmap ' ' output.nifti_rtmap ' -R ' input.template ' --use-BSpline ' input.warp];
    unix(cmd)
end

% Resample the tmap to its original size
if tmap_temp_sr(1)~=100 || tmap_temp_sr(2)~=100 || tmap_temp_sr(3)~=100
    tmap_temp_sr=(1./(tmap_temp_sr./100)).*100;
    cmd = ['c3d ' output.nifti_rtmap ' -resample ' num2str(tmap_temp_sr(1)) '%x' num2str(tmap_temp_sr(2)) '%x' num2str(tmap_temp_sr(3)) '% -o ' output.nifti_rtmap];
    unix(cmd)
end

% Convert the transformed tmap back to it's original format (.img)
cmd = ['fslchfiletype_exe ANALYZE ' output.nifti_rtmap];
unix(cmd)

end
