function [kspace_centered,rspace_centered] = rspace_centering(kspace,rspace,datafdf,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Center rspace
[nx,ny,nz,nt] = size(rspace);
if param.center_rspace == 1
    if isfield(param,'central_positionx') && isfield(param,'central_positiony')
        centerx=param.central_positionx;
        centery=param.central_positiony;
    else
        centerx=round(nx/2);
        centery=round(ny/2);
    end
elseif param.center_rspace == 2
    max_pos_datafdf = rspace_max(datafdf);
    centerx=max_pos_datafdf(:,1);
    centery=max_pos_datafdf(:,2);
end
max_pos = rspace_max(rspace);
x_shift = max_pos(:,1)-centerx;
y_shift = max_pos(:,2)-centery;
x_shift = round(x_shift);
y_shift = round(y_shift);

for t=1:nt
    for z=1:nz
        [kspace_centered(:,:,z,t)] = phase_ramp_addition(kspace(:,:,z,t),x_shift(z),y_shift(z));
        if param.fourier2D==1 && param.correction<5
            rspace_centered(:,:,z,t) = (fftshift(ifft2(kspace_centered(:,:,z,t))));
        else
            for x=1:param.knx
                rspace_centered(x,:,z,t) = (fftshift(ifft(kspace_centered(x,:,z,t))));
            end
        end
    end
end

%% Eliminating the double sampling in the frequency direction
if param.double_freq_sampling
    rspace_centered=rspace_centered(param.knx/4+1:3*param.knx/4,:,:,:);
end

%% Flip LR
% rspace_centered = rspace_centered(end:-1:1,:,:,:);

%% Flip UD
% rspace_centered = rspace_centered(:,end:-1:1,:,:);

end

