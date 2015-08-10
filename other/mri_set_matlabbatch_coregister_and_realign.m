function matlabbatch = mri_set_matlabbatch_coregister_and_realign(fnameTemplate,image_path)

matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[fnameTemplate ',1']};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[image_path ',1']};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 3;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [1 1 1];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';