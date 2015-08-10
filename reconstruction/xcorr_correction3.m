function [kspace] = xcorr_correction3(kspace,param)
% Correct odd and even echoes mismatch individually for each column
%%
for t=1:param.nt
    for z=1:param.knz
        for y=param.columns_to_correct
            odd_column=y+1;
            even_column=y;
            % Compute the cross correlation between the 2 columns
            odds = abs(kspace(:,odd_column,z,t));
            odds_smoothed = imfilter(odds,param.gauss_1D);
            evens = abs(kspace(:,even_column,z,t));
            evens_smoothed = imfilter(evens,param.gauss_1D);
            cross_corr = xcorr(odds_smoothed,evens_smoothed);
            precise_max_yzt(y,z,t) = precise_max(cross_corr,param);
            precise_max_yzt(y,z,t) = precise_max_yzt(y,z,t)-param.knx/2;
            % Interpolate the new Kspace
            if y==param.columns_to_correct(1)
                for ybegin=2:2:y
                    x=1:param.knx;
                    Y=kspace(:,ybegin,z,t);
                    xi=(1:param.knx) + param.central_position - precise_max_yzt(y,z,t);
                    kspace(:,ybegin,z,t) = interp1(x,Y,xi);
                end
            elseif y==param.columns_to_correct(end)
                for yend=y:2:param.ny
                    x=1:param.knx;
                    Y=kspace(:,yend,z,t);
                    xi=(1:param.knx) + param.central_position - precise_max_yzt(y,z,t);
                    kspace(:,yend,z,t) = interp1(x,Y,xi);
                end
            else
                x=1:param.knx;
                Y=kspace(:,y,z,t);
                xi=(1:param.knx) + param.central_position - precise_max_yzt(y,z,t);
                kspace(:,y,z,t) = interp1(x,Y,xi);
            end
        end
    end
end
kspace(isnan(kspace)) = 0;    %eliminate the NaN


end

