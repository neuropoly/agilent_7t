function matlabbatch = mri_matlabbatch_dicom_to_nifti(path0,pathNii,scan,N,Nslice)
scans = {};
for s0=1:Nslice
    for i0=1:N
        fname = fullfile(path0,[scan '.dcm'],['slice' gen_num_str(s0,3) 'image' gen_num_str(i0,3) 'echo001.dcm']);
        scans = [scans; fname];
        V = dicominfo(fname);
        Y = dicomread(fname);
        V.AcquisitionNumber = i0; %Add acquisition number
        V.SeriesNumber = i0;
        V.PatientID = 'EPI';
        dicomwrite(Y,fname,V);
    end
end
matlabbatch{1}.spm.util.dicom.data = scans;
matlabbatch{1}.spm.util.dicom.root = 'flat';
matlabbatch{1}.spm.util.dicom.outdir = {pathNii};
matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
