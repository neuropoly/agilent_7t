function icm_t5Dto4D(fname)
nii=load_nii(fname);
nii.hdr.dime.dim(1)=4;
nii.hdr.dime.dim(5:6)=nii.hdr.dime.dim([6 5]);
save_nii(nii,fname)