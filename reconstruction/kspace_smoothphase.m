function kspace_sm=kspace_smoothphase(kspace)
        
[~,Ind]=max(abs(kspace),[],1);

for iZ=1:size(kspace,3)
    for iY=1:size(kspace,2)
        phase=double(angle(kspace(:,iY,iZ))); phase=phase(:)';
        magn=abs(kspace(:,iY,iZ)); magn=magn(:)';
        phase_uw=unwrap(phase,3.5); [~,Ind]=max((magn-min(magn)+1)./(phase_uw-min(phase_uw)+1));
        
        t=1:size(kspace,1); t2=t(max(Ind-25,1):min(Ind+25,size(kspace,1)));
        [fitresult, ~] = SmoothFit(t2,phase_uw(t2));
        phase_uw_sm(:,iY,iZ)=phase_uw; phase_uw_sm(t2,iY,iZ)=feval(fitresult,t2);

%         t=1:size(kspace,1); t2=t([max(Ind-25,1):max(Ind-4,1), min(Ind+4,size(kspace,1)):min(Ind+25,size(kspace,1))]);
%         [fitresult, ~] = LinearFit(t2, phase_uw(t2), Ind);
%         phase_uw_sm(:,iY,iZ)=feval(fitresult,t); phase_uw_sm(max(Ind-4,1):min(Ind+4,size(kspace,1)),iY,iZ)=phase_uw(max(Ind-4,1):min(Ind+4,size(kspace,1)));

%         t=1:size(kspace,1); t2=t(max(Ind-25,1):max(Ind-4,1)); t3=t(min(Ind+4,size(kspace,1)):min(Ind+25,size(kspace,1)));
%         p2=polyfit(t2,phase_uw(t2),1); p3=polyfit(t3,phase_uw(t3),1);
%         phase_uw_sm(t(t<max(Ind-4,1)),iY,iZ)=polyval(p2,t(t<max(Ind-4,1))); phase_uw_sm(t(t>min(Ind+4,size(kspace,1))),iY,iZ)=polyval(p3,t(t>min(Ind+4,size(kspace,1))));
%         phase_uw_sm(t(t>=max(Ind-4,1) & t<=min(Ind+4,size(kspace,1))), iY, iZ) = phase_uw(t(t>=max(Ind-4,1) & t<=min(Ind+4,size(kspace,1))));
    end
end
kspace_sm = abs(kspace).*exp(-1i.*wrapToPi(phase_uw_sm));



function [fitresult, gof] = SmoothFit(t2,u)


% Fit
[xData, yData] = prepareCurveData( t2, u );

% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.SmoothingParam = 0.05;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure(23);
% h = plot( fitresult, xData, yData );
% legend( h, 'phase vs. t2', 'fit', 'Location', 'NorthEast' );
% % Label axes
% xlabel( 't2' );
% ylabel( 'phase' );
% grid on
% 

function [fitresult, gof] = LinearFit(t2, phaset2, echotime)


% Fit
[xData, yData] = prepareCurveData( t2, phaset2);

% Set up fittype and options.
ft = fittype( ['a*abs(x-' num2str(echotime) ')+c'], 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [0.0975404049994095 0.278498218867048];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure(23);
% h = plot( fitresult, xData, yData );
% legend( h, 'phase vs. t2', 'fit', 'Location', 'NorthEast' );
% % Label axes
% xlabel( 't2' );
% ylabel( 'phase' );
% grid on
% 

