function [kspace_filtered] = kspace_median_filtering(kspace)
% kspace_median_filtering
% This function finds values are usually associated with a spike artefact
% in the kspace and replaces them with a median value. A value is
% considered wrong when it exceeds by a certain factor (tolerance) the
% median value of its phase encoded line.

%%
[nx,ny,nz,nt]=size(kspace);
dim_min = min([nx,ny]);
% max_size_filter = round(dim_min/30);

mean_kspace = mean(kspace,4);
tolerance=100;
% gauss_filter_strong = fspecial('gaussian',[round(nx/4) round(ny/4)],round(nx/8));
kspace_filtered = kspace;
nb_replacement=0;
for t=1:nt
    for z=1:nz
        for x=1:nx
            lin = kspace(x,:,z,t);
            med_value = median(abs(lin));
            verif_med = abs(lin)>med_value*tolerance;
            if sum(verif_med(:)) > 0
                nb_replacement = nb_replacement+1;
                if x<=nx/16
                    %                     kspace_filtered(round(1:x+nx/16),verif_med,z,t) = med_value;
                elseif x>=15*nx/16
                    %                     kspace_filtered(round(x-nx/16:nx),verif_med,z,t) = med_value;
                else
                    disp(['modifying t=' num2str(t) ', z=' num2str(z) ', x=' num2str(x)])
                    kspace_filtered(round(x-nx/16:x+nx/16),verif_med,z,t) = med_value;
                end
            end
        end
    end
end

if nb_replacement>nt
    disp('Too many replacement. Restarting with higher tolerance')
    tolerance = tolerance*2;
    for t=1:nt
        for z=1:nz
            for x=1:nx
                lin = kspace(x,:,z,t);
                med_value = median(abs(lin));
                verif_med = abs(lin)>med_value*tolerance;
                if sum(verif_med(:)) > 0
                    if x<=nx/16
                        %                     kspace_filtered(round(1:x+nx/16),verif_med,z,t) = med_value;
                    elseif x>=15*nx/16
                        %                     kspace_filtered(round(x-nx/16:nx),verif_med,z,t) = med_value;
                    else
                        disp(['modifying t=' num2str(t) ', z=' num2str(z) ', x=' num2str(x)])
                        kspace_filtered(round(x-nx/16:x+nx/16),verif_med,z,t) = med_value;
                    end
                end
            end
        end
    end
end

end

