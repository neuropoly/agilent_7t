function [tsnr3d] = evaluate_tsnr(input)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
[nx,ny,nz,nt] = size(input);
nb_voxels = nx*ny*nz;
i_progress = 0;
pourcentage = 10;
data2d = reshape(input,nb_voxels,nt);

for i_vox = 1:nb_voxels
	data1d = data2d(i_vox,:);
	% compute TSNR
	tsnr(i_vox) = mean(data1d) / std(data1d);
	% display progress
% 	if i_progress > nb_voxels/10;
% 		disp(['.. ',num2str(pourcentage),'/100'])
% 		pourcentage = pourcentage + 10;
% 		i_progress = 0;
% 	else
% 		i_progress = i_progress+1;
% 	end
end
tsnr3d = reshape(tsnr,nx,ny,nz);

end

