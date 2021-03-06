function matlabbatch = mri_set_matlabbatch_old_rats_realign_smooth(pathNii,N,remove_first_scan)
scans = {};
if remove_first_scan
    first_scan = 2;
else
    first_scan = 1;
end
for i0=first_scan:N
    scans = [scans; fullfile(pathNii,['volume' gen_num_str(i0,3) '.nii,1'])];
end
matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                    scans
                                                    }';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 1; %1 mm for mouse or rat
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 0.5; %0.5 mm for mouse or rat
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; %0: register to first, 1: register to mean
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep;
matlabbatch{2}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.spatial.smooth.data(1).sname = 'Realign: Estimate & Reslice: Resliced Images (Sess 1)';
matlabbatch{2}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.spatial.smooth.data(1).src_output = substruct('.','sess', '()',{1}, '.','rfiles');
matlabbatch{2}.spm.spatial.smooth.fwhm = [0.8 0.8 2];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';
