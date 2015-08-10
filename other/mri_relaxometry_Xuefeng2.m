function mri_relaxometry_Xuefeng2
%For Xuefeng
try
    show_sample_fig = 1;
    divide_by_two = 0; %if matrix size is 64x64 rather than 128x128
    %select mode: T2, T2* or T1
    mode = 0;
    robust = 0;
    remove_doubling = 0;
    switch mode
        case 0 %T2
            mode_str = 'T2';
            sequence_str = 'sems';
            sequence_offset = 0; %possible offset in enumeration of images
            path = '/Users/liom/Documents/IRM_scans/s_date_09_Xuefeng1/sems05.nii/';
            %echo times in ms
            x1 = [15 30 45 60 75 90 120 240];
        case 2 %T1
            mode_str = 'T1';
            sequence_str = 'sems';
            sequence_offset = 0;
            path = '/Users/liom/Documents/IRM_scans/s_date_09_Xuefeng1/sems04.nii//';
            %Inversion times in ms
            x1 = [7 10 30 50 70 100 300 500 700 1000 1300 1600 2000 2500];
    end
    %do baseline correction
    baseline_correction = 0;
    
    %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
    %of their centers in pixels
    %Number of ROIs
        NROI = 27;
    
    %radii of ROIs (for ellipses)
    r1 = 2;
    r2 = 2;
    %coordinates of ROIs -- going clockwise from top left
    %horizontal, vertical coordinates
    for i0=1:6
        for j0=1:4
            v{i0,j0} =
    v{
    
    
    if GdOn
        v{1} = [39+17 22-2]; %Gd from top: 1  0    -- too far up for probe
        v{2} = [39+17 30-2]; %Gd from top: 2  0.1
        v{3} = [39+17 38-2]; %Gd from top: 3  0.45
        v{4} = [38+17 46-2]; %Gd from top: 4  0.8
        v{5} = [38+17 55-2]; %Gd from top: 5  0?
        v{6} = [46+9 66+9]; %Gd from bottom: 6  5
        v{7} = [45+9 75+9]; %Gd from bottom: 5  3
        v{8} = [46+9 84+9]; %Gd from bottom: 4  1
        v{9} = [46+9 93+9]; %Gd from bottom: 3  0.6
        v{10} = [46+9 102+9]; %Gd from bottom: 2 0.3
        v{11} = [46+9 111+9]; %Gd from bottom: 1  0 -- too far down for probe
        c(1) = 0;
        c(2) = 0.1;
        c(3) = 0.45;
        c(4) = 0.8;
        c(5) = 0;
        c(6) = 5;
        c(7) = 3;
        c(8) = 1;
        c(9) = 0.6;
        c(10) = 0.3;
        c(11) = 0;
    else
        %from top: 1  0.1: eliminated  -- outside of probe
        v{1} = [67 25]; %FeMnO from top: 2  0.2
        v{2} = [67 34]; %FeMnO from top: 3  0.3
        v{3} = [67 42]; %FeMnO from top: 4  0.4
        v{4} = [67 51]; %FeMnO from top: 5  0.5
        v{5} = [76 65]; %FeMnO from bottom: 6 2.5
        v{6} = [76 75]; %FeMnO from bottom: 5  1.5
        v{7} = [76 84]; %FeMnO from bottom: 4  1
        v{8} = [76 93]; %FeMnO from bottom: 3  0.8
        v{9} = [76 102]; %FeMnO from bottom: 2  0.6
        v{10} = [76 110]; %FeMnO from bottom: 1  0
        c(1) = 0.2;
        c(2) = 0.3;
        c(3) = 0.4;
        c(4) = 0.5;
        c(5) = 2.5;
        c(6) = 1.5;
        c(7) = 1;
        c(8) = 0.8;
        c(9) = 0.6;
        c(10) = 0;
    end
    if divide_by_two
        for i0=1:NROI
            v{i0} = round(v{i0}/2);
        end
        r1 = round(r1/2);
        r2 = round(r2/2);
    end
    if mode == 2
        %specify before which scan the sign of data needs to be flipped
        if GdOn
            ISc{1} = 11; %Gd
            ISc{2} = 10; %Gd
            ISc{3} = 8; %Gd
            ISc{4} = 7; %Gd
            ISc{5} = 12; %Gd
            ISc{6} = 7; %12; %Gd
            ISc{7} = 7; %Gd
            ISc{8} = 8; %Gd
            ISc{9} = 9; %Gd
            ISc{10} = 12; %Gd
            ISc{11} = 12; %Gd
            
            
        else
            ISc{1} = 11; %FeMnO
            ISc{2} = 11; %FeMnO
            ISc{3} = 10; %FeMnO
            ISc{4} = 10; %FeMnO
            ISc{5} = 12; %FeMnO
            ISc{6} = 11; %FeMnO
            ISc{7} = 12; %FeMnO
            ISc{8} = 12; %FeMnO
            ISc{9} = 11; %FeMnO
            ISc{10} = 12; %FeMnO
        end
    else
        if mode == 3
            %specify before which scan the sign of data needs to be flipped
            ISc{1} = 12;
            ISc{2} = 12;
            ISc{3} = 12;
            ISc{4} = 13;
            ISc{5} = 12;
            ISc{6} = 12;
            ISc{7} = 12;
            ISc{8} = 12;
        end
    end
    
    
    Ya = [];
    TP = length(x1); %number of time points -- echo times or inversion times
    
    for iTP=1:TP
        switch mode
            case 0
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
            case 1
                file = fullfile(path,[sequence_str gen_num_str(iTP+sequence_offset,2) '.nii'],['volume' gen_num_str(1,4) '.nii']);
            case 2
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
            case 3
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
                
        end
        V = spm_vol(file);
        Y0{iTP} = spm_read_vols(V)';
        if remove_doubling
            Y0{iTP} = Y0{iTP}(:,1:end/2);
        end
        Ya = [Ya Y0{iTP}];
    end
    Y = Y0;
    if show_sample_fig
        figure; imagesc(Ya)
        %form time series
        figure; imagesc(Y0{1})
    end
    y0 = zeros(TP,NROI);
    %yl0 = zeros(TP,NROI);
    for iROI=1:NROI
        for iTP=1:TP
            tmp = 0;
            ct = 0;
            for z1 = v{iROI}(1)-r1:v{iROI}(1)+r1
                for z2 = v{iROI}(2)-r2:v{iROI}(2)+r2
                    if (z1-v{iROI}(1))^2+(z2-v{iROI}(2))^2 <= r1^2+r2^2
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
    if baseline_correction
        for iROI=1:NROI
            for iTP=1:TP
                switch mode
                    case 0
                        y{iROI}(iTP) = y{iROI}(iTP)-y{iROI}(end);
                        y0(iTP,iROI) = y0(iTP,iROI)-y0(end,iROI);
                    case 1
                        
                    case 2
                        
                end
            end
        end
    end
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
    switch mode
        case 0
            for iROI=1:NROI
                [beta,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT2,[1e6 30],options);
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
            for iROI=1:NROI
                [betaInv,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT2Inv,[1e6 1/30],options);
                T2Inv(iROI) = 1/betaInv(2);
                mseT2Inv(iROI) = tmse;
                sigT2Inv(iROI) = COVB(2,2)^0.5;
                beta1T2Inv(iROI) = betaInv(1);
                %estimates
                yp(:,iROI) = fitT2Inv(betaInv,x1);
                
            end
            T0Inv = 1./T2Inv;
            S0Inv = sigT2Inv;
            
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
            
            for iROI=1:NROI
                [betaInv,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT1Inv,[1e7 1/2000 1e7],options);
                T1Inv(iROI) = 1/betaInv(2);
                mseT1Inv(iROI) = tmse;
                sigT1Inv(iROI) = COVB(2,2)^0.5;
                beta1T1Inv(iROI) = beta(1);
                beta3T1Inv(iROI) = beta(3);
                %estimates
                yp(:,iROI) = fitT1Inv(betaInv,x1);
                
            end
            T0Inv = 1./T1Inv;
            S0Inv = sigT1Inv;
        case 3
            for iROI=1:NROI
                [beta,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT1,[1e7 2600 1e7],options);
                T1(iROI) = beta(2);
                mseT1(iROI) = tmse;
                sigT1(iROI) = COVB(2,2)^0.5;
                beta1T1(iROI) = beta(1);
                beta3T1(iROI) = beta(3);
                %estimates
                yp(:,iROI) = fitT1(beta,x1);
                
            end
            T1
            sigT1
            mseT1
            beta1T1
            beta3T1
    end
    figure; plot(x1,y0,':'); hold on; plot(x1,yp,'-');
    figure; r0=[10]; plot(x1,y0(:,r0),':'); hold on; plot(x1,yp(:,r0),'-');
    a=1;
    if GdOn
        switch mode
            case 0
                figure; plot(c(2:end-1),1000./T0(2:end-1),'x');
                figure; errorbar(c(2:end-1),1000*T0Inv(2:end-1),1000*S0Inv(2:end-1),'x'); hold on
                axis([0 2 0 100]);
                keep = [2:5 8:10];
                fobj = fit(c(keep)',1000*T0Inv(keep)','poly1')
                xP = linspace(0,2,20);
                plot(xP,fobj.p2+fobj.p1*xP,'r')
                title(['Gd: r2 = ' num2str(fobj.p1,3) ' s^-1mM^-1 + ' num2str(fobj.p2,3) ' s^-1']);
            case 2
                keep0 = 2:10;
                figure; plot(c(keep0),1000./T0(keep0),'x');
                figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
                axis([0 6 0 8]);
                keep = 2:10; %[2:5 8:10];
                fobj = fit(c(keep)',1000*T0Inv(keep)','poly1')
                xP = linspace(0,5,20);
                plot(xP,fobj.p2+fobj.p1*xP,'r')
                title(['Gd: r1 = ' num2str(fobj.p1,3) ' s^-1mM^-1 + ' num2str(fobj.p2,3) ' s^-1']);
        end
        
    else
        switch mode
            case 0
                keep0 = 1:10; 
                figure; plot(c(keep0),1000./T0(keep0),'x');
                figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
                axis([0 3 0 150]);
                keep = [1:4 10];
                fobj = fit(c(keep)',1000*T0Inv(keep)','poly1')
                xP = linspace(0,2,20);
                plot(xP,fobj.p2+fobj.p1*xP,'r')
                title(['FeMnO: r2 = ' num2str(fobj.p1,3) ' s^-1mM^-1 + ' num2str(fobj.p2,3) ' s^-1']);
            case 2
                keep0 = 1:10; %[1:4 10];
                figure; plot(c(keep0),1000./T0(keep0),'x');
                figure; errorbar(c(keep0),1000*T0Inv(keep0),1000*S0Inv(keep0),'x'); hold on
                axis([0 3 0 8]);
                keep = [1:4 10];
                fobj = fit(c(keep)',1000*T0Inv(keep)','poly1')
                xP = linspace(0,5,20);
                plot(xP,fobj.p2+fobj.p1*xP,'r')
                title(['FeMnO: r1 = ' num2str(fobj.p1,3) ' s^-1mM^-1 + ' num2str(fobj.p2,3) ' s^-1']);
        end
    end
    
    %recall: cftool
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    
end
