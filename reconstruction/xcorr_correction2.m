function [kspace] = xcorr_correction2(kspace,param)
% Correct odd and even echoes mismatch with the 2 most correlated odd/even 
% columns of each scan using cross_correlation
%%
for t=1:param.nt
    for z=1:param.knz
        % Determine the most correlated odd/even columns of each slices from each scan
        for y=1:param.ny-1
            auto_corr(y,z,t) = corr(abs(kspace(:,y,z,t)),abs(kspace(:,y+1,z,t)));
        end
        [best_corr(z,t) best_corr_pos(z,t)] = max(auto_corr(:,z,t));
        if mod(best_corr_pos(z,t),2)
            odd_column=best_corr_pos(z,t);
            even_column=best_corr_pos(z,t)+1;
        else
            odd_column=best_corr_pos(z,t)+1;
            even_column=best_corr_pos(z,t);
        end
        % Compute the cross correlation between those 2 columns
        odds = abs(kspace(:,odd_column,z,t));
        odds_smoothed = imfilter(odds,param.gauss_1D);
        evens = abs(kspace(:,even_column,z,t));
        evens_smoothed = imfilter(evens,param.gauss_1D);
        cross_corr = xcorr(odds_smoothed,evens_smoothed);
        precise_max_zt(z,t) = precise_max(cross_corr,param);
        precise_max_zt(z,t) = precise_max_zt(z,t)-param.knx/2;
    end
end
if param.median_smoothing
    for t=1:param.nt
        for z=1:param.knz
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
for t=1:param.nt
    for z=1:param.knz
        for y=2:2:param.ny
            x=1:param.knx;
            Y=kspace(:,y,z,t);
            xi=(1:param.knx) + param.central_position - precise_max_zt(z,t);
            kspace(:,y,z,t) = interp1(x,Y,xi);
        end
    end
end
kspace(isnan(kspace)) = 0;    %eliminate the NaN


end

