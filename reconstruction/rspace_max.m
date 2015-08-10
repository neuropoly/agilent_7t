function [max_position] = rspace_max(rspace)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[nx,ny,nz,nt] = size(rspace);
mean_rspace = mean(rspace(:,:,:,1:nt-1),4);

for z=1:nz
    gauss_filter_strong = fspecial('gaussian',[round(nx/4) round(ny/4)],round(nx/8));
    % Strong filtering
    filt_mean_recon = conv2(abs(mean_rspace(:,:,z)),gauss_filter_strong,'same');
    % Find the maximum
    [~,max_pos] = max(filt_mean_recon(:));
    max_pos_y = ceil(max_pos/nx);
    max_pos_x = mod(max_pos,nx);
    max_position(z,:) = [max_pos_x max_pos_y];
end
diff_max_pos = sum(max_position(2:nz,:) - max_position(1:nz-1,:));

end
