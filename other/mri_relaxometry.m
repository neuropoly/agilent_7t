function mri_relaxometry
try
    %select mode: T2, T2* or T1
    mode = 2;
    remove_doubling = 0;
    switch mode
        case 0 %T2
            mode_str = 'T2';
            sequence_str = 'sems';
            remove_doubling = 1;
            sequence_offset = 4; %possible offset in enumeration of images
            do_inversion = 0;
            %Inputs
            path = '/Users/liom/Documents/111214_Tina_SEMS_T2/';
            %times chosen by user: echo times for T2, inversion times for T1
            x1 = [15.1, 17, 20, 25, 35, 50, 70]; %, 100, 140, 200, 300, 500];
            %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
            %of their centers in pixels
            %Number of ROIs
            NROI = 10;
            %radii of ROIs (for ellipses)
            r1 = 2;
            r2 = 5;
            %coordinates of ROIs
            v{1} = [23 32]; %0 %old samples
            v{2} = [45 26]; %4 ng Fe/mL
            v{3} = [71 28]; %40
            v{4} = [96 30]; %400
            v{5} = [120 32]; %4000
            v{6} = [11 92]; %0 %new samples
            v{7} = [34 94]; %5.2 ng Fe/mL
            v{8} = [59 96]; %52
            v{9} = [83 94]; %520
            v{10} = [108 94]; %5200
        case 1 %T2*
            mode_str = 'T2*';
            sequence_str = 'gemsT2star';
            sequence_offset = 0;
            path = '/Users/liom/Documents/111215_Tina_GEMS_T2star/';
            remove_doubling = 1;
            sequence_offset = 0; %possible offset in enumeration of images
            do_inversion = 0;
            %times chosen by user: echo times for T2star
            x1 = [2.75, 4, 6, 8, 10, 12, 14, 16.96]; 
            %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
            %of their centers in pixels
            %Number of ROIs
            NROI = 10;
            y64 = 1;
            %radii of ROIs (for ellipses)
            if y64
                r1 = 1;
                r2 = 2;
                ydiv = 2;
            else 
                r1 = 2;
                r2 = 5;
                ydiv = 1;
            end
            
            %coordinates of ROIs
            horiz_offset = 4;
            v{1} = [round(23/ydiv) round((32+horiz_offset)/ydiv)]; %0 %old samples
            v{2} = [round(45/ydiv) round((26+horiz_offset)/ydiv)]; %4 ng Fe/mL
            v{3} = [round(71/ydiv) round((28+horiz_offset)/ydiv)]; %40
            v{4} = [round(96/ydiv) round((30+horiz_offset)/ydiv)]; %400
            v{5} = [round(120/ydiv) round((32+horiz_offset)/ydiv)]; %4000
            v{6} = [round(10/ydiv) round((94+horiz_offset)/ydiv)]; %0 %new samples
            v{7} = [round(34/ydiv) round((94+horiz_offset)/ydiv)]; %5.2 ng Fe/mL
            v{8} = [round(59/ydiv) round((96+horiz_offset)/ydiv)]; %52
            v{9} = [round(83/ydiv) round((94+horiz_offset)/ydiv)]; %520
            v{10} = [round(108/ydiv) round((94+horiz_offset)/ydiv)]; %5200
            
        case 2 %T1
            mode_str = 'T1';
            sequence_str = 'sems';
            sequence_offset = 0;
            remove_doubling = 1;
            sequence_offset = 0;
            do_inversion = 1;
            
            T1dataset = 4;
            switch T1dataset
                case 1 %base case: 8 dp, default SEMS parameters for inversion recovery
                    %Inputs
                    %path = '/Users/liom/Documents/111215_Tina_SEMS_T1/semsT103.nii/';
                    path = 'I:\111215_Tina_SEMS_T1\semsT103.nii\';
                    %times chosen by user: inversion times (TI) for T1
                    x1 = [10, 19, 36.2, 68.8, 131, 249, 473, 900];
                    Ninverted_points = length(x1)-2;
                    y64 = 0;
                case 2 %much longer TR=2000ms, 16 datapoints, targeting 400 ms
                    %Inputs
                    %path = '/Users/liom/Documents/111215_Tina_SEMS_T1_2000_16dp_near400/semsT101.nii/';
                    path = 'I:\111215_Tina_SEMS_T1_2000_16dp_near400\semsT101.nii\';
                    %times chosen by user: inversion times (TI) for T1
                    x1 = [10, 13.8, 18.9, 26.1, 35.8, 49.3, 67.9, 93.4, 128, 177, 243, 335, 461, 634, 872, 1200];
                    Ninverted_points = length(x1)-2;
                    y64 = 1;
                case 3 %TR=3000ms, 16dp targeting 900 ms, min at 100ms
                    %path = '/Users/liom/Documents/111215_Tina_SEMS_T1_3000_16dp_near_900/semsT103.nii/';
                    path = 'I:\111215_Tina_SEMS_T1_3000_16dp_near_900\semsT103.nii\';
                    x1 = [100, 125, 155, 193, 241, 300, 374, 466, 580, 722, 900, 1120, 1400, 2200, 2700];
                     Ninverted_points = length(x1)-5;
                    y64 = 1;
                    
                case 4 %TR=4000ms, 8 dp targeting 1300 ms, min at 100 ms
                    %path = '/Users/liom/Documents/111215_Tina_SEMS_T1_4000_8dp_near1300/semsT104.nii/';
                    path = 'I:\111215_Tina_SEMS_T1_4000_8dp_near1300\semsT104.nii\';
                    x1 = [100, 167, 278, 465, 775, 1290, 2200, 3600];
                     Ninverted_points = length(x1)-3;
                    y64 = 1;
            end
            
            %specify number of ROIs, their radius in pixels, and the coordinates (x,y)
            %of their centers in pixels
            %Number of ROIs
            NROI = 10;
            %radii of ROIs (for ellipses)
            if y64
                r1 = 1;
                r2 = 3;
                ydiv = 2;
            else 
                r1 = 2;
                r2 = 5;
                ydiv = 1;
            end
            
            %coordinates of ROIs
            horiz_offset = 4;
            v{1} = [round(23/ydiv) round((32+horiz_offset)/ydiv)]; %0 %old samples
            v{2} = [round(45/ydiv) round((26+horiz_offset)/ydiv)]; %4 ng Fe/mL
            v{3} = [round(71/ydiv) round((28+horiz_offset)/ydiv)]; %40
            v{4} = [round(96/ydiv) round((30+horiz_offset)/ydiv)]; %400
            v{5} = [round(120/ydiv) round((32+horiz_offset)/ydiv)]; %4000
            v{6} = [round(10/ydiv) round((92+horiz_offset)/ydiv)]; %0 %new samples
            v{7} = [round(34/ydiv) round((94+horiz_offset)/ydiv)]; %5.2 ng Fe/mL
            v{8} = [round(59/ydiv) round((96+horiz_offset)/ydiv)]; %52
            v{9} = [round(83/ydiv) round((94+horiz_offset)/ydiv)]; %520
            v{10} = [round(108/ydiv) round((94+horiz_offset)/ydiv)]; %5200
            
    end
    %do baseline correction
    baseline_correction = 0;
    
    
    Ya = [];
    TP = length(x1);
    
    for iTP=1:TP
        switch mode
            case 0
                file = fullfile(path,[sequence_str gen_num_str(iTP+sequence_offset,2) '.nii'],['volume' gen_num_str(1,4) '.nii']);
            case 1
                file = fullfile(path,[sequence_str gen_num_str(iTP+sequence_offset,2) '.nii'],['volume' gen_num_str(1,4) '.nii']);
            case 2
                file = fullfile(path,['volume' gen_num_str(iTP,4) '.nii']);
        end
        V = spm_vol(file);
        Y0{iTP} = spm_read_vols(V)';
        if remove_doubling
            Y0{iTP} = Y0{iTP}(:,1:end/2);
        end
        if do_inversion
            if iTP <= Ninverted_points
                %invert signal
                Y0{iTP} = -Y0{iTP};
            end
        end
                
        Ya = [Ya Y0{iTP}];
    end
    Y = Y0;
    figure; imagesc(Ya); 
    %form time series
    
    figure; imagesc(Y0{1}); hold on
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
                        tmp = tmp+Y{iTP}(z1,z2);
                        if iTP == 1
                            plot(z2,z1,'oy')
                        end
                    end
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
    figure; plot(x1,y0)
    %figure; plot(x1,yl0)
    
    yp = zeros(TP,NROI);
    for iROI=1:NROI
        switch mode
            case 0 %T2
                [beta,r0,J,COVB,tmse] = nlinfit(x1,y{iROI},@myexp,[9e5 -0.01]);
                T2(iROI) = -1/beta(2);
                mse(iROI) = tmse;
                
                %estimates
                yp(:,iROI) = myexp(beta,x1);
            case 1
                [beta,r0,J,COVB,tmse] = nlinfit(x1,y{iROI},@expT2star,[y0(1,iROI) 5]);
                T2star(iROI) = beta(2);
                mse(iROI) = tmse;
                
                %estimates
                yp(:,iROI) = expT2star(beta,x1);
            case 2 %T1
                %note: change value of TR manually in function expT1
                [beta,r0,J,COVB,tmse] = nlinfit(x1,y{iROI},@expT1,[y0(end,iROI) 1300]);
                T1(iROI) = beta(2);
                mse(iROI) = tmse;
                %estimates
                yp(:,iROI) = expT1(beta,x1); %[beta(1) 300]
                
        end
    end
    switch mode
        case 0
            T2
        case 1
            T2star
        case 2
            T1
    end
    mse
    figure; plot(x1,y0,':'); hold on; plot(x1,yp,'-');
    %recall: cftool
    a=1;
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    
end
