function icm_convert_dmri_fmri(input_folders,output_folder,recon,param)
% input_folders='/Volumes/users_hd2/tanguy/data/Montreal/Animal7T/20140219_Pig+cat+AxCaliber+MTV+QMT/s_2014021202_Julien3/epip*qspace*D20*';
% output_folder='./'
% icm_convert_dmri_fmri(input_folders,output_folder, (recon#))
% examples:
% icm_convert_dmri_fmri('home/s_2014021202_Julien3/epip_diff_qspace_D*','./')
% icm_convert_dmri_fmri('home/s_2014021202_Julien3/epip_diff_qspace_D*','./',5)
%

if nargin<2
    help icm_convert_dmri_fmri
end

% convert to nifti
if nargin<3
    recon=[];
    icm_fdf_to_dicom_or_nifti_auto(input_folders)
else
    % homemade recon
    incell=sct_tools_ls(input_folders,1);
    if nargin<4, param{1}.outputphase=0; end
    icm_fid_recon(incell{1},recon,param)
end
% get diffusion parameters
icm_procpar2bvec_file(input_folders)

% move to current folder
icm_move_v4d(input_folders,output_folder,recon)