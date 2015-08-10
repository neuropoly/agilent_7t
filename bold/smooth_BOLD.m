function smooth_BOLD(pathNii,param)
files_nii = {};
N = param.nt;
if exist([pathNii filesep 'rvolume001.nii'])
    for i0=1:N
        files_nii = [files_nii; fullfile(pathNii,['rvolume' gen_num_str(i0,3) '.nii,1'])];
        if ~exist(fullfile(pathNii,['srvolume' gen_num_str(i0,3) '.nii']),'file')
            matlabbatch{1}.spm.spatial.smooth.data(1) = cfg_dep;
            matlabbatch{1}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
            matlabbatch{1}.spm.spatial.smooth.data(1).sname = 'Realign: Estimate & Reslice: Resliced Images (Sess 1)';
            matlabbatch{1}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
            matlabbatch{1}.spm.spatial.smooth.data(1).src_output = substruct('.','sess', '()',{1}, '.','rfiles');
            matlabbatch{1}.spm.spatial.smooth.fwhm = [1.2 1.2 1]; %[0.4 0.4 1];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch);
        end
    end
elseif exist([pathNii filesep 'volume001.nii'])
    for i0=1:N
        files_nii= [files_nii; fullfile(pathNii,['volume' gen_num_str(i0,3) '.nii,1'])];
        if ~exist(fullfile(pathNii,['svolume' gen_num_str(i0,3) '.nii']),'file')
            matlabbatch{1}.spm.spatial.smooth.data(1) = cfg_dep;
            matlabbatch{1}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
            matlabbatch{1}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
            matlabbatch{1}.spm.spatial.smooth.data(1).sname = 'Realign: Estimate & Reslice: Resliced Images (Sess 1)';
            matlabbatch{1}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
            matlabbatch{1}.spm.spatial.smooth.data(1).src_output = substruct('.','sess', '()',{1}, '.','rfiles');
            matlabbatch{1}.spm.spatial.smooth.fwhm = [1.2 1.2 1]; %[0.4 0.4 1];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch);
        end
        
    end
end
end
