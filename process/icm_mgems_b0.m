function icm_mgems_b0(Phase,Magn,TE2)
% icm_mgems_b0(Phase,Magn,TE2)
% example: icm_mgems_b0('Phase.nii','Magn.nii',5e-3)
tmp_folder=sct_tempdir;
sct_gunzip(Phase,tmp_folder, 'Phase.nii');
sct_gunzip(Magn,tmp_folder, 'Magn.nii');
cd(tmp_folder)
sct_unix('prelude -p Phase.nii -a Magn.nii -o Ph_uw -f')
b0=load_nii('Ph_uw.nii.gz');
b0map=(b0.img(:,:,:,2)-b0.img(:,:,:,1))/TE2/2/pi;
cd ..
save_nii_v2(b0map,'b0map',Magn)