function matlabbatch = mri_set_matlabbatch_te_dicom_to_nifti(path0,pathNii,scan,Nte,Nslice)
scans = {};
if ~exist(pathNii,'dir'), mkdir(pathNii); end
for s0=1:Nslice
    for i0=1:Nte
        fname = fullfile(path0,[scan '.dcm'],['slice' gen_num_str(s0,3) 'image' gen_num_str(i0,3) 'echo001.dcm']);
        scans = [scans; fname];
        V = dicominfo(fname);
        Y = dicomread(fname);
        V.AcquisitionNumber = i0; %Add acquisition number
        V.SeriesNumber = i0;
        V.PatientID = 'GE'; %?
        dicomwrite(Y,fname,V);
    end
end
matlabbatch{1}.spm.util.dicom.data = scans;
matlabbatch{1}.spm.util.dicom.root = 'flat';
matlabbatch{1}.spm.util.dicom.outdir = {pathNii};
matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
spm_jobman('run',matlabbatch);
%rename the files
[files,dirs] = spm_select('FPList',pathNii,'.*');
for t0 = 1:size(files,1)
    [dir0 fil0 ext0] = fileparts(files(t0,:));
    movefile(files(t0,:),fullfile(dir0,['echo' gen_num_str(t0,3) '.nii']));
end
