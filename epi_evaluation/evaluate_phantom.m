function [tspr,signal,phantom,std_phantom] = evaluate_phantom(input,output)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
if isstruct(input)
    recon_name = fieldnames(input);
    nb_recon = length(recon_name);
    [nx,ny,nz,nt] = size(getfield(input,recon_name{1}));
else 
    nb_recon=1;
    [nx,ny,nz,nt] = size(input);
end
gauss_filter_strong = fspecial('gaussian',[round(nx/4) round(ny/4)],round(nx/8));
gauss_filter_weak = fspecial('gaussian',[round(nx/8) round(ny/8)],round(nx/16));
for i=1:nb_recon
    if isstruct(input)
        recon = abs(getfield(input,recon_name{i}));
    else
        recon = abs(input);
    end    
    mean_recon = mean(recon,4);
    %         figure(i)
    for z=1:nz
        % Strong filtering
        filt_mean_recon = conv2(mean_recon(:,:,z),gauss_filter_strong,'same');
        % Find the maximum
        [~,max_pos] = max(filt_mean_recon(:));
        max_pos_y = ceil(max_pos/nx);
        max_pos_x = mod(max_pos,nx);
        max_pos_recon(i,z,:) = [max_pos_x+nx max_pos_y+ny];
        % Translate by half the fov in the phase direction to find the
        % phantom
        phantom_pos(i,z,:) = max_pos_recon(i,z,:);
        if phantom_pos(i,z,2)>round(ny/2)+ny
            phantom_pos(i,z,2) = phantom_pos(i,z,2)-round(ny/2);
        else
            phantom_pos(i,z,2) = phantom_pos(i,z,2)+round(ny/2);
        end
        rep_recon = repmat(recon,[3,3,1,1]);
        for t=1:nt
            filt_recon = conv2(rep_recon(:,:,z,t),gauss_filter_weak,'same');
            signal(i,z,t) = filt_recon(max_pos_recon(i,z,1),max_pos_recon(i,z,2));
            phantom(i,z,t) = filt_recon(phantom_pos(i,z,1),phantom_pos(i,z,2));
            std_phantom(i,z,t) = std2(rep_recon(max_pos_recon(i,z,1)-round(nx/16):max_pos_recon(i,z,1)+round(nx/16),...
                max_pos_recon(i,z,2)-round(ny/16) : max_pos_recon(i,z,2)+round(ny/16)));
            tspr(i,z,t) = (signal(i,z,t)-phantom(i,z,t))/std_phantom(i,z,t);
        end
    end
end

%% display
% display_evaluate_phantom(tspr,signal,phantom,input,output)

end