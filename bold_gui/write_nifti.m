function write_nifti(B0,dirBOLDnii)
if ~exist(dirBOLDnii,'dir')
    mkdir(dirBOLDnii);
    [nx ny nt nz] = size(B0);
    V.dim = [nx ny nz];
    V.mat = eye(4);
    V.dt = [4 1];
    for i0=1:nt
        FilenameNii = fullfile(dirBOLDnii,['volume' gen_num_str(i0,3) '.nii']);
        Y = squeeze(B0(:,:,i0,:));
        V.fname = FilenameNii;
        spm_write_vol(V,Y);
    end    
end