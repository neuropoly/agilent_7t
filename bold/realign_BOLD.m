function realign_BOLD(pathNii,param)
files_nii = {};
N = param.nt;
for i0=1:N
    files_nii = [files_nii; fullfile(pathNii,['volume' gen_num_str(i0,3) '.nii,1'])];
end
if ~exist(fullfile(pathNii,['rvolume' gen_num_str(i0,3) '.nii']),'file')
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {files_nii}';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 1; %1 mm for mouse or rat
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 0.5; %0.5 mm for mouse or rat
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0; %0: register to first, 1: register to mean
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    spm_jobman('run',matlabbatch);
end