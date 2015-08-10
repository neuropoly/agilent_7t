function mri_write_real_imag_to_dicom(f_path0,scan,K)
K = mri_fft_no_abs(K);
Re = real(K); Im = imag(K);
f_pathD = fullfile(f_path0,[scan '.dcm\']);
f_pathR = fullfile(f_path0,[scan 'real.dcm\']);
f_pathI = fullfile(f_path0,[scan 'imag.dcm\']);
if ~exist(f_pathR,'dir'), mkdir(f_pathR); end
if ~exist(f_pathI,'dir'), mkdir(f_pathI); end
[nx ny nz ne] = size(K);
for z0=1:nz
    for e0=1:ne
        name0 = ['slice' gen_num_str(z0,3) 'image' gen_num_str(e0,3) 'echo001.dcm'];
        fname = fullfile(f_pathD,name0);
        V = dicominfo(fname);
        do_write(f_pathR,name0,squeeze(Re(:,:,z0,e0)),V);
        do_write(f_pathI,name0,squeeze(Im(:,:,z0,e0)),V);
    end
end
%then write to nifti
f_pathR_Nii = fullfile(f_path0,[scan 'real.nii\']);
mri_set_matlabbatch_te_dicom_to_nifti(f_path0,f_pathR_Nii,scan,ne,nz);
f_pathI_Nii = fullfile(f_path0,[scan 'imag.nii\']);
 mri_set_matlabbatch_te_dicom_to_nifti(f_path0,f_pathI_Nii,scan,ne,nz);

function do_write(f_path1,name0,Y,V)
V.Filename = fullfile(f_path1,name0);
%Y = mri_fft_no_abs(Y);
Y = double(Y);
dicomwrite(Y,V.Filename,V);
