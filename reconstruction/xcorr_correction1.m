function [kspace] = xcorr_correction1 (kspace,param)
% Correct odd and even echoes mismatch with the central columns of each 
% scan using cross_correlation of multiple central columns

%%
nb_columns = length(param.odd_columns);
for t=1:size(kspace,4)
    for z=1:size(kspace,3)
        odds = mean(abs(kspace(:,param.odd_columns,z,t)),2);
        [~,odds_max] = max(odds,[],1);
        for y=1:2:size(kspace,2)-1
            kspace(:,y,z,t) = circshift(kspace(:,y,z,t),param.central_positionx-odds_max);
        end
        for y=1:nb_columns
            odds = abs(kspace(:,param.odd_columns(y),z,t));
            odds_smoothed = imfilter(odds,param.gauss_1D);
            evens = abs(kspace(:,param.even_columns(y),z,t));
            evens_smoothed = imfilter(evens,param.gauss_1D);
            cross_corr = xcorr(odds_smoothed,evens_smoothed);
            precise_max_yzt(y,z,t) = precise_max(cross_corr,param);
            precise_max_yzt(y,z,t) = precise_max_yzt(y,z,t);
        end
        % Average of the displacement between the odd and even columns
        precise_max_zt(z,t) = mean(precise_max_yzt(:,z,t),1);
        precise_max_zt(z,t) = precise_max_zt(z,t)-param.knx/2;
    end
end
if param.median_smoothing
    for t=1:size(kspace,4)
        for z=1:size(kspace,3)
            if t<6
                precise_max_zt_smoothed(z,t) = median(precise_max_zt(z,1:t));
            elseif t>param.nt-6
                precise_max_zt_smoothed(z,t) = median(precise_max_zt(z,t-5:param.nt));
            else
                precise_max_zt_smoothed(z,t) = median(precise_max_zt(z,t-5:t+5));
            end
        end
    end
    precise_max_zt=precise_max_zt_smoothed;
end
% Interpolate the new Kspace
for t=1:size(kspace,4)
    for z=1:size(kspace,3)
        for y=2:2:size(kspace,2)
            x=1:param.knx;
            Y=kspace(:,y,z,t);
            xi=(1:param.knx) + param.central_positionx - precise_max_zt(z,t);
            kspace(:,y,z,t) = interp1(x,Y,xi);
        end
    end
end
kspace(isnan(kspace)) = 0;    %eliminate the NaN
end

