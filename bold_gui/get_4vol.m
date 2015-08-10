function Y = get_4vol(scans)
Y = [];
for i0=1:length(scans)
    V = spm_vol(scans{i0});
    if i0==1
        dim = V.dim;
        Y = zeros([dim length(scans)]);
    end
    Y(:,:,:,i0) = spm_read_vols(V);
end