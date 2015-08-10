function matlabbatch = mri_set_matlabbatch_cardiacBOLD_dicom_to_nifti(path0,pathNii,scan,N,CardiacFrame)
scans = {};
for i0=1:N
    fname = fullfile(path0,[scan '.dcm'],['slice001image' gen_num_str(i0,3) 'echo' gen_num_str(CardiacFrame,3) '.dcm']);
    fnameO = fullfile(path0,[scan '.dcm'],['slice001image' gen_num_str(i0,3) 'echo001.dcm']);
    scans = [scans; fnameO];
    V = dicominfo(fname);
    Y = dicomread(fname);
    V.fname = fnameO;
    V.AcquisitionNumber = i0; %Add acquisition number
    V.SeriesNumber = i0;
    V.PatientID = 'CINE';
    dicomwrite(Y,fname,V);
end
matlabbatch{1}.spm.util.dicom.data = scans;
matlabbatch{1}.spm.util.dicom.root = 'flat';
matlabbatch{1}.spm.util.dicom.outdir = {pathNii};
matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
