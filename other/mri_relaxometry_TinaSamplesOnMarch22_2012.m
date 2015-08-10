function mri_relaxometry
try
    show_sample_fig = 1;
    divide_by_two = 0; %if matrix size is 64x64 rather than 128x128
    %select mode: T2, T2* or T1
    mode = 2;
    robust =0;
    remove_doubling = 0;
    switch mode
        case 0 %T2
            mode_str = 'T2';
            sequence_str = 'sems_T1';
            sequence_offset = 0; %possible offset in enumeration of images
            %sequence_offset = 8;
            %sequence_offset = 16;
            path = '/Users/liom/Documents/IRM_scans/s_2012032003/';
            %echo times in ms
            x1 = [15 30 45 60 75 90 120 240];
        case 1 %T2*
            mode_str = 'T2*';
            sequence_str = 'gems_T1';
            sequence_offset = 0;
            %echo times in ms
            x1 = [3 5 7 10 15 20 30 40 50];
            path = '/Users/liom/Documents/IRM_scans/s_2012032003/';
        case 2 %T1
            mode_str = 'T1';
            sequence_str = 'sems';
            sequence_offset = 0;
            %path = '/Users/liom/Documents/IRM_scans/s_2012032003/semsIR14_T1_T101.nii/';
            path = '/Users/liom/Documents/IRM_scans/s_2012032003/semsIR14_T1_T102.nii/';
            %path = '/Users/liom/Documents/IRM_scans/s_2012032003/semsIR14_T1_T103.nii/';
            %Inversion times in ms
            x1 = [5 7 10 30 50 70 100 300 500 700 1000 1300 1600 2000];
        case 3 %gemsIR -- T1?
            mode_str = 'T1';
            sequence_str = 'gemsir_T1';
            sequence_offset = 0;
            path = '/Users/liom/Documents/IRM_scans/s_2012032003/gemsir_T101.nii/';
            %Inversion times in ms
            x1 = [5 7 10 30 50 70 100 300 500 700 1000 1300 1600 2000];
            
    end
    %do baseline correction
    baseline_correction = 0;
    
    %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
    %of their centers in pixels
    %Number of ROIs
    NROI = 8;
    %radii of ROIs (for ellipses)
    r1 = 3;
    r2 = 3;
    %coordinates of ROIs -- going clockwise from top left
    %horizontal, vertical coordinates
    v{1} = [30 16]; %
    v{2} = [54 15]; %
    v{3} = [76 16]; %
    v{4} = [78 40]; %
    v{5} = [74 62]; %
    v{6} = [51 62]; %
    v{7} = [28 62]; %
    v{8} = [27 38]; %
    if divide_by_two
        for i0=1:NROI
            v{i0} = round(v{i0}/2);
        end
        r1 = round(r1/2);
        r2 = round(r2/2);
    end
    if mode == 2
        %specify before which scan the sign of data needs to be flipped
        ISc{1} = 13;
        ISc{2} = 13;
        ISc{3} = 13;
        ISc{4} = 13;
        ISc{5} = 13;
        ISc{6} = 13;
        ISc{7} = 13;
        ISc{8} = 13;
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
                file = fullfile(path,[sequence_str gen_num_str(iTP+sequence_offset,2) '.nii'],['volume' gen_num_str(1,4) '.nii']);
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
                [beta,r0,J,COVB,tmse] = nlinfit(x1',y{iROI}',@fitT2,[1e7 100],options);
                T2(iROI) = beta(2);
                mseT2(iROI) = tmse;
                sigT2(iROI) = COVB(2,2)^0.5;
                beta1T2(iROI) = beta(1);
                %estimates
                yp(:,iROI) = fitT2(beta,x1);
                
            end
            T2
            sigT2
            mseT2
            beta1T2
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
    a=1;
    %recall: cftool
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    
end
