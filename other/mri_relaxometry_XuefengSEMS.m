function mri_relaxometry_XuefengSEMS
resolution = 1; %128x128:0  256x256:1
calc_maps = 1; %boolean to calculate T1 or T2 maps
%calc_relaxometry(0,resolution,calc_maps); %T2
calc_relaxometry(2,resolution,calc_maps); %T1

function calc_relaxometry(mode,resolution,calc_maps)
%For Xuefeng
try
    show_sample_fig = 1;
    show_circles = 0;
    %resolution,if matrix size is 256x256 rather than 128x128
    %select mode: T2, T2* or T1
    robust = 0;
    switch mode
        case 0 %T2
            mode_str = 'T2';
            if resolution
                sequence_str = 'sems06';
            else
                sequence_str = 'sems04';
            end
            %sequence_offset = 0; %possible offset in enumeration of images
            path = ['/Users/liom/Documents/IRM_scans/XuefengSEMS1/' sequence_str '.nii'];
            %echo times in ms
            x1 = [6.8 8 10 12 15 20 25 35 45 60 90 120 240];
        case 2 %T1
            mode_str = 'T1';
            if resolution
                sequence_str = 'sems07';
            else
                sequence_str = 'sems05';
            end
            %sequence_offset = 0;
            path = ['/Users/liom/Documents/IRM_scans/XuefengSEMS1/' sequence_str '.nii'];
            %Inversion times in ms
            x1 = [6 10 30 50 70 100 300 500 700 900 1100 1400 1700 2100 2500];
    end
    %do baseline correction
    baseline_correction = 0;
    
    %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
    %of their centers in pixels
    %Number of ROIs
    NROI = 24;
    
    %radii of ROIs (for ellipses)
    r1 = 4;
    r2 = 4;
    r1msk = r1+2;
    r2msk = r2+2;
    %coordinates of ROIs -- going clockwise from top left
    %horizontal, vertical coordinates
    for i0=1:4
        for j0=1:6
            v{i0,j0} = [42+17*(i0-1)+floor((i0-1)/2) 11+18*(j0-1)-floor((j0-1)/2)];
            if j0 == 6 || j0 == 5
                v{i0,j0} = v{i0,j0} + [2 0];
            end
            
        end
    end
    if resolution
        msk = zeros(256,256);
    else
        msk = zeros(128,128);
    end
    %Further adjustments:
    v{1,1} = v{1,1}; % + [-1 1];
    v{3,1} = v{3,1} + [-1 -1];
    v{4,1} = v{4,1} + [-1 0];
    v{4,2} = v{4,2} + [0 -1];
    
    v{1,3} = v{1,3} + [0 1];
    
    v{3,2} = v{3,2} + [0 -1];
    v{3,4} = v{3,4} + [1 0];
    
    v{2,4} = v{2,4} + [1 0];
    v{1,5} = v{1,5} + [-1 1];
    v{4,1} = v{4,1} + [0 -1];
    v{4,4} = v{4,4} + [1 -1];
    v{4,3} = v{4,3} + [1 -1];
    
    v{3,5} = v{3,5} + [-1 0];
    v{2,5} = v{2,5} + [0 1];
    
    v{3,6} = v{3,6} + [0 -1];
    v{4,6} = v{4,6} + [0 -1];
    if resolution
        for i0=1:NROI
            v{i0} = v{i0}*2;
        end
        r1 = 2*r1;
        r2 = 2*r2;
        r1msk = 2*r1msk;
        r2msk = 2*r2msk;
    end
    %mask
    msk_roi = zeros(size(msk));
    for i0=1:4
        for j0=1:6
            for z1 = v{i0,j0}(1)-r1msk:v{i0,j0}(1)+r1msk
                for z2 = v{i0,j0}(2)-r2msk:v{i0,j0}(2)+r2msk
                    if (z1-v{i0,j0}(1))^2+(z2-v{i0,j0}(2))^2 <= ((r1msk+r2msk)/2)^2
                        msk(z2,z1) = 1; %z2, z1 flipped because of Matlab convention on matrices
                        msk_roi(z2,z1) = i0+4*(j0-1);
                    end
                end
            end
        end
    end
    %enumerate the ROIs
    ct = 0;
    for j0=1:6
        for i0=1:4
            ct = ct+1;
            w{ct} = v{i0,j0};
        end
    end
    %concentrations
    c(1) = 0;
    c(2) = 0.1; %Gd
    c(3) = 0.3;
    c(4) = 0.5;
    c(5) = 0.8;
    c(6) = 1.2;
    c(7) = 1.8;
    c(8) = 2.3;
    c(9) = 3;
    c(10) = 3.5;
    c(11) = 5;
    c(12) = 7;
    c(13) = 0.005; %Fe
    c(14) = 0.01;
    c(15) = 0.03;
    c(16) = 0.05;
    c(17) = 0.1;
    c(18) = 0.2;
    c(19) = 0.4;
    c(20) = 0.8;
    c(21) = 1.2;
    c(22) = 1.5;
    c(23) = 2;
    c(24) = 2.5;
    
    if mode == 0
        %echo times to use, depending on sample -- this is to capture the
        %exponential decay of samples that decay very quickly
        %minimum = 3, since it takes at least 3 points to fit the curve
        nET(1:NROI) = length(x1);
        nET(5) = 9;
        nET(6) = 6;
        nET(7:12) = 3;
        nET(19) = 6;
        nET(20) = 4;
        nET(21:22) = 3;
        nET(21) = 2;
        if resolution == 1
            nET(11:12) = 6;
            nET(10) = 8;
        end
        
    end
    if mode == 2
        nET(1:NROI) = length(x1);
    end
    
    if mode == 2
        %specify before which scan the sign of data needs to be flipped
        %if GdOn
        ISc{1} = 11; %Gd
        ISc{2} = 9; %Gd
        ISc{3} = 7; %Gd
        ISc{4} = 7; %Gd
        ISc{5} = 7; %Gd
        ISc{6} = 7; %12; %Gd
        ISc{7} = 7; %Gd
        ISc{8} = 8; %Gd
        ISc{9} = 9; %Gd
        ISc{10} = 9; %Gd
        ISc{11} = 10; %Gd
        ISc{12} = 10; %Gd
        ISc{13} = 11; %FeMnO
        ISc{14} = 10; %FeMnO
        ISc{15} = 10; %FeMnO
        ISc{16} = 10; %FeMnO
        ISc{17} = 10; %FeMnO
        ISc{18} = 10; %FeMnO
        ISc{19} = 9; %FeMnO
        ISc{20} = 9; %FeMnO
        ISc{21} = 8; %FeMnO
        ISc{22} = 9; %FeMnO
        ISc{23} = 9; %FeMnO
        ISc{24} = 9; %FeMnO
    end
    
    TP = length(x1); %number of time points -- echo times or inversion times
    if resolution
        Ya = zeros(TP,256,256);
    else
        Ya = zeros(TP,128,128);
    end
    
    for iTP=1:TP
        switch mode
            case 0
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
            case 2
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
        end
        V = spm_vol(file);
        Y0{iTP} = spm_read_vols(V)'; %transposition here -- makes x<->y confusing
        Ya(iTP,:,:) = Y0{iTP};
    end
    Y = Y0;
    if show_sample_fig
        %figure; imagesc(Ya)
        %form time series
        if show_circles
            figure; imagesc(Y0{1}); hold on
            for i0=1:4
                for j0=1:6
                    plot(v{i0,j0}(1), v{i0,j0}(2),'xr');
                    for z1 = v{i0,j0}(1)-r1:v{i0,j0}(1)+r1
                        for z2 = v{i0,j0}(2)-r2:v{i0,j0}(2)+r2
                            if (z1-v{i0,j0}(1))^2+(z2-v{i0,j0}(2))^2 <= ((r1+r2)/2)^2
                                plot(z1,z2,'or');
                            end
                        end
                    end
                end
            end
        end
        figure; imagesc(Y0{1}.*msk);
    end
    y0 = zeros(TP,NROI);
    %yl0 = zeros(TP,NROI);
    for iROI=1:NROI
        for iTP=1:TP
            tmp = 0;
            ct = 0;
            for z1 = w{iROI}(1)-r1:w{iROI}(1)+r1
                for z2 = w{iROI}(2)-r2:w{iROI}(2)+r2
                    if (z1-w{iROI}(1))^2+(z2-w{iROI}(2))^2 <= ((r1+r2)/2)^2
                        ct = ct+1;
                        tmp = tmp+Y{iTP}(z2,z1);
                    end
                end
            end
            if mode == 2 || mode == 3
                if iTP < ISc{iROI}
                    %flip the sign
                    tmp = -tmp;
                end
            end
            y{iROI}(iTP) = tmp/ct;
            %yl{i}(j) = log(y{i}(j));
            y0(iTP,iROI) = y{iROI}(iTP);
            %yl0(j,i) = yl{i}(j);
        end
    end
    %baseline shift
    %     if baseline_correction
    %         for iROI=1:NROI
    %             for iTP=1:TP
    %                 switch mode
    %                     case 0
    %                         y{iROI}(iTP) = y{iROI}(iTP)-y{iROI}(end);
    %                         y0(iTP,iROI) = y0(iTP,iROI)-y0(end,iROI);
    %                     case 2
    %
    %                 end
    %             end
    %         end
    %     end
    %figure; plot(x1,y0)
    %figure; plot(x1,yl0)
    if robust
        statset('nlinfit');
        options = statset('robust','on');
    else
        statset('nlinfit');
        options = statset('robust','off');
    end
    yp = zeros(TP,NROI);
    if resolution
        axis0 = [30 110 0 95]*2;
    else
        axis0 = [30 110 0 95];
    end
    switch mode
        case 0
            for iROI=1:NROI
                disp(['Fit T2, ROI ' int2str(iROI)]);
                ytmp = y{iROI}';
                [beta,r0,J,COVB,tmse] = nlinfit(x1(1:nET(iROI))',ytmp(1:nET(iROI)),@fitT2,[1e6 30],options);
                T2(iROI) = beta(2);
                mseT2(iROI) = tmse;
                sigT2(iROI) = COVB(2,2)^0.5;
                beta1T2(iROI) = beta(1);
                %estimates
                yp(:,iROI) = fitT2(beta,x1);
                
            end
            T0 = T2;
            S0 = sigT2;
            T2
            sigT2
            mseT2
            beta1T2
            %             for iROI=1:NROI
            %                 disp(['Fit T2 INV, ROI ' int2str(iROI)]);
            %                 ytmp = y{iROI}';
            %                 [betaInv,r0,J,COVB,tmse] = nlinfit(x1(1:nET(iROI))',ytmp(1:nET(iROI)),@fitT2Inv,[1e6 1/30],options);
            %                 T2Inv(iROI) = 1/betaInv(2);
            %                 mseT2Inv(iROI) = tmse;
            %                 sigT2Inv(iROI) = COVB(2,2)^0.5;
            %                 beta1T2Inv(iROI) = betaInv(1);
            %                 %estimates
            %                 yp(:,iROI) = fitT2Inv(betaInv,x1);
            %
            %             end
            %             T0Inv = 1./T2Inv;
            %             S0Inv = sigT2Inv;
            if calc_maps
                warning('off')
                keep_rois = [1:8 13:20];
                T2map = zeros(size(msk));
                sigT2map = zeros(size(msk));
                %warning('off','
                for z1=1:size(msk,1)
                    for z2=1:size(msk,2)
                        if msk(z2,z1)
                            %find which ROI
                            roi = msk_roi(z2,z1);
                            if any(roi == keep_rois)
                                ytmp = squeeze(Ya(:,z2,z1));
                                %fit
                                try
                                    [beta,r0,J,COVB,tmse] = nlinfit(x1(1:nET(roi))',ytmp(1:nET(roi)),@fitT2,[1e6 30],options);
                                    T2map(z2,z1) = beta(2);
                                    sigT2map(z2,z1) = COVB(2,2)^0.5;
                                catch
                                    disp(['Failed for ' int2str(z1) ' x ' int2str(z2)]);
                                end
                            end
                        end
                    end
                end
                T2map0 = T2map;
                T2map(T2map>90) = 0;
                T2map(T2map<3) = 0;
                sigT2map(sigT2map>4) = 0;
                sigT2map(sigT2map<0) = 0;
                figure; imagesc(sigT2map)
                colormap(hot); colorbar; axis(axis0)
                title('Standard deviation of T2 (ms)')
                figure; imagesc(T2map)
                colormap(hot); colorbar; axis(axis0)
                title('T2 (ms)')
                R2map = 1000./T2map0;
                R2map(R2map<0) = 0;
                R2map(R2map>500) = 0;
                figure; imagesc(R2map)
                colormap(hot); colorbar; axis(axis0)
                title('R2 (s^{-1})')
                warning('on')
                a=1;
            end
            
        case 1
            for iROI=1:NROI
                [beta,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT2,[1e7 20],options);
                T2star(iROI) = beta(2);
                mseT2star(iROI) = tmse;
                sigT2star(iROI) = COVB(2,2)^0.5;
                beta1T2star(iROI) = beta(1);
                %estimates
                yp(:,iROI) = fitT2star(beta,x1);
                
            end
            T2star
            sigT2star
            mseT2star
            beta1T2star
        case 2
            for iROI=1:NROI
                disp(['Fit T1, ROI ' int2str(iROI)]);
                [beta,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT1,[1e7 500 1e7],options);
                T1(iROI) = beta(2);
                mseT1(iROI) = tmse;
                sigT1(iROI) = COVB(2,2)^0.5;
                beta1T1(iROI) = beta(1);
                beta3T1(iROI) = beta(3);
                %estimates
                yp(:,iROI) = fitT1(beta,x1);
                
            end
            T0 = T1;
            S0 = sigT1;
            T1
            sigT1
            mseT1
            beta1T1
            beta3T1
            %
            %             for iROI=1:NROI
            %                 disp(['Fit T1 INV, ROI ' int2str(iROI)]);
            %                 [betaInv,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT1Inv,[1e7 1/2000 1e7],options);
            %                 T1Inv(iROI) = 1/betaInv(2);
            %                 mseT1Inv(iROI) = tmse;
            %                 sigT1Inv(iROI) = COVB(2,2)^0.5;
            %                 beta1T1Inv(iROI) = beta(1);
            %                 beta3T1Inv(iROI) = beta(3);
            %                 %estimates
            %                 yp(:,iROI) = fitT1Inv(betaInv,x1);
            %
            %             end
            %             T0Inv = 1./T1Inv;
            %             S0Inv = sigT1Inv;
            
            if calc_maps
                warning('off')
                keep_rois = [1:8 13:20];
                keep_rois = 1:24;
                T1map = zeros(size(msk));
                sigT1map = zeros(size(msk));
                %warning('off','
                for z1=1:size(msk,1)
                    for z2=1:size(msk,2)
                        if msk(z2,z1)
                            %find which ROI
                            roi = msk_roi(z2,z1);
                            if any(roi == keep_rois)
                                ytmp = squeeze(Ya(:,z2,z1));
                                %need to do inversions
                                for m0=1:length(ytmp)
                                    if m0 < ISc{roi}
                                        ytmp(m0) = -ytmp(m0);
                                    end
                                end
                                %fit
                                try
                                    [beta,r0,J,COVB,tmse] = nlinfit(x1(1:nET(roi))',ytmp(1:nET(roi)),@fitT1,[1e7 1000 1e6],options);
                                    T1map(z2,z1) = beta(2);
                                    sigT1map(z2,z1) = COVB(2,2)^0.5;
                                catch
                                    disp(['Failed for ' int2str(z1) ' x ' int2str(z2)]);
                                end
                            end
                        end
                    end
                end
                T1map0 = T1map;
                T1map(T1map>3000) = 0;
                T1map(T1map<0) = 0;
                sigT1map(sigT1map>100) = 0;
                sigT1map(sigT1map<0) = 0;
                figure; imagesc(sigT1map)
                colormap(hot); colorbar;
                axis(axis0)
                title('Standard deviation of T1 (ms)')
                figure; imagesc(T1map)
                colormap(hot); colorbar; axis(axis0)
                title('T1 (ms)')
                R1map = 1000./T1map0;
                R1map(R1map<0) = 0;
                R1map(R1map>5) = 0;
                figure; imagesc(R1map)
                colormap(hot); colorbar; axis(axis0)
                title('R1 (s^{-1})')
                warning('on')
                a=1;
            end
            
            
    end
    figure; plot(x1,y0,'x'); hold on; plot(x1,yp,'-');
    figure; r0=[1:7]; plot(x1,y0(:,r0),'x'); hold on; plot(x1,yp(:,r0),'-');
    a=1;
    %Sample fit accuracy
    lsp{1} = 'xb'; lsp{2} = ['og']; lsp{3} = '+r'; lsp{4} = 'sc'; lsp{5} = 'dm'; lsp{6} = '^y';
    lsp{7} = '>k'; lsp{8} = 'pb'; lsp{9} = '<g'; lsp{10} = 'hr'; lsp{11} = '.c';
    set(0,'DefaultAxesColorOrder',[0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 0; 0 0 0; 0 0 1; 0 1 0; 1 0 0; 1 0 1])
    
    switch mode
        case 0
            
            figure; r0=[1:7]; for k0=1:length(r0), plot(x1,y0(:,r0(k0)),lsp{k0}); hold on; end
            plot(x1,yp(:,r0),'-');
            xlabel('Echo time (ms)')
            ylabel('Gd sheets, spatially average intensity (a.u.)')
            legend('0','0.1','0.3','0.5','0.8','1.2','1.8')
            
            figure; r0=[1 13:20]; for k0=1:length(r0), plot(x1,y0(:,r0(k0)),lsp{k0}); hold on; end
            plot(x1,yp(:,r0),'-');
            xlabel('Echo time (ms)')
            ylabel('FeMnO, spatially averaged intensity (a.u.)')
            legend('0','0.005','0.01','0.3','0.05','0.1','0.2','0.4','0.8')
            
            %figure 1
            %                 keep0Gd = 1:7;
            %                 figure; plot(c(keep0Gd),1000./T2(keep0Gd),'xb'); hold on
            %                 keep0Fe = [13:20];
            %                 plot(c(keep0Fe),1000./T2(keep0Fe),'or');
            %                 axis([0 2 0 350]);
            %                 xlabel('Concentration (mM)')
            %                 ylabel('R2')
            %figure 2
            keep0Gd = 1:7;
            keep0Fe = [13:20];
            S2 = 1000 *( -1./(T2+sigT2) + 1./T2);
            figure;
            
            keepGd = 1:7;
            fobj = fit(c(keepGd)',1000./T2(keepGd)','poly1')
            xP = linspace(0,2,20);
            
            plot(xP,fobj.p2+fobj.p1*xP,'b'); hold on
            keepFe = [1 13:20];
            fobj2 = fit(c(keepFe)',1000./T2(keepFe)','poly1')
            plot(xP,fobj2.p2+fobj2.p1*xP,'r')
            
            errorbar(c(keep0Gd),1000./T2(keep0Gd),S2(keep0Gd),'xb'); hold on
            errorbar(c(keep0Fe),1000./T2(keep0Fe),S2(keep0Fe),'or'); hold on
            axis([0 2 0 350]);
            xlabel('Concentration C (mM)')
            ylabel('R2 (1 SD error bars)')
            
            %figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
            %axis([0 2 0 350]);
            
            
            legend(['Gd sheets: r2 = ' num2str(fobj.p1,3) ' C s^{-1}mM^{-1} + ' num2str(fobj.p2,3) ' s^{-1}'],...
                ['FeMnO: r2 = ' num2str(fobj2.p1,3) ' C s^{-1}mM^{-1} + ' num2str(fobj2.p2,3) ' s^{-1}']);
            
            a=1;
            
            
        case 2
            
            figure; r0=[1:7]; for k0=1:length(r0), plot(x1,y0(:,r0(k0)),lsp{k0}); hold on; end
            plot(x1,yp(:,r0),'-');
            xlabel('Inversion time (ms)')
            ylabel('Gd sheets, spatially average intensity (a.u.)')
            legend('0','0.1','0.3','0.5','0.8','1.2','1.8')
            
            figure; r0=[1 13:20]; for k0=1:length(r0), plot(x1,y0(:,r0(k0)),lsp{k0}); hold on; end
            plot(x1,yp(:,r0),'-');
            xlabel('Inversion time (ms)')
            ylabel('FeMnO, spatially averaged intensity (a.u.)')
            legend('0','0.005','0.01','0.3','0.05','0.1','0.2','0.4','0.8')
            
            %figure 1
            %                 keep0Gd = 1:7;
            %                 figure; plot(c(keep0Gd),1000./T2(keep0Gd),'xb'); hold on
            %                 keep0Fe = [13:20];
            %                 plot(c(keep0Fe),1000./T2(keep0Fe),'or');
            %                 axis([0 2 0 350]);
            %                 xlabel('Concentration (mM)')
            %                 ylabel('R2')
            %figure 2
            keep0Gd = 1:7;
            keep0Fe = [13:21];
            S1 = 1000 *( -1./(T1+sigT1) + 1./T1);
            figure;
            keepGd = [1:5];
            keepGd2 = [1:7];
            fobj3 = fit(c(keepGd)',1000./T1(keepGd)','poly2')
            xP = linspace(0,2,20);
            plot(xP,fobj3.p3+fobj3.p2*xP+fobj3.p1*xP.^2,'b-'); hold on
            
            
            fobj = fit(c(keepGd)',1000./T1(keepGd)','poly1')
            xP = linspace(0,2,20);
            plot(xP,fobj.p2+fobj.p1*xP,'b-.'); hold on
            
            keepFe = [1 13:20];
            fobj2 = fit(c(keepFe)',1000./T1(keepFe)','poly1')
            plot(xP,fobj2.p2+fobj2.p1*xP,'r')
            
            
            errorbar(c(keep0Gd),1000./T1(keep0Gd),S1(keep0Gd),'xb'); hold on
            errorbar(c(keep0Fe),1000./T1(keep0Fe),S1(keep0Fe),'or'); hold on
            axis([0 2 0 5]);
            xlabel('Concentration C (mM)')
            ylabel('R1 (1 SD error bars)')
            
            %figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
            %axis([0 2 0 350]);
            
            
            
            legend(['Gd sheets: r1 = ' num2str(fobj3.p1,3) ' C^2 s^{-1}mM^{-2} + ' num2str(fobj3.p2,3) ' C s^{-1}mM^{-1} + ' num2str(fobj3.p3,3) ' s^{-1}'],...
                ['Gd sheets: r1 = ' num2str(fobj.p1,3) ' C s^{-1}mM^{-1} + ' num2str(fobj.p2,3) ' s^{-1}'],...
                ['FeMnO: r1 = ' num2str(fobj2.p1,3) ' C s^{-1}mM^{-1} + ' num2str(fobj2.p2,3) ' s^{-1}']);
            
            
            
            %                 keep0 = 1:10; %[1:4 10];
            %                 figure; plot(c(keep0),1000./T0(keep0),'x');
            %                 figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
            %                 axis([0 3 0 8]);
            %                 keep = [1:4 10];
            %                 fobj = fit(c(keep)',1000*T0Inv(keep)','poly1')
            %                 xP = linspace(0,5,20);
            %                 plot(xP,fobj.p2+fobj.p1*xP,'r')
            %                 title(['FeMnO: r1 = ' num2str(fobj.p1,3) ' s^-1mM^-1 + ' num2str(fobj.p2,3) ' s^-1']);
    end
    a=1;
    
    %recall: cftool
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    
end
