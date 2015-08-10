function path_stat = mri_BOLD_CO2_old_rats(subj)
try
    mainPath = fullfile(filesep,'Volumes','hd2_local','users_local','jfpp','data','hypercapnia');
    asl = 0;
    runEPI = 1;
    [rat_MRI_order rat_name path_rat path_epip path_fsems ...
        Nepip ons dur dur_eff ons_delay] = load_hypercapnia_rat_dat(runEPI,mainPath);
%     subj = 4:24; %19:24; % [1 3 4]; % [9 11:20]; %4:19; %[14:19]; %[7:12]; %
    pathA = fullfile(mainPath,'Analysis');
    force_T1 = 0;
    force_preprocess = 0;
    force_stats = 0;
    remove_first_scan = 1;
    if remove_first_scan
        first_scan = 2;
    else
        first_scan = 1;
    end
    use_physiology = 0;
    HPF = 240; %in seconds; default: 240 s = 4 minutes
    interp_option = 'nearest';
    scaling_GLM = 1; %'Scaling'; %None
    MVT = 1; %boolean, whether to include movement parameters or not in GLM
    %fsems_to_epi_ratio = 4;
    
    for su = subj
        cr = rat_MRI_order(su); %current rat
        path0 = path_rat{cr};
        scan = path_epip{cr};
        fsems_scan = path_fsems{cr};
        pathNii = fullfile(path0,[scan '.nii']);
        %TR0 = TR{cr};
        N = Nepip{cr};
        ons_delay0 = ons_delay{cr};
        ons0 = ons{cr}+ons_delay0;
        dur0 = dur{cr};
        dur_eff0 = dur_eff{cr};
        Stat0 = ['StatD' int2str(dur_eff0(1)) '_d' int2str(ons_delay0) '_m' int2str(MVT) '_S' int2str(scaling_GLM) '_R' int2str(runEPI)];
        Stat1 = [Stat0 '_' interp_option];
        nameID = [gen_num_str(cr,2) '_' gen_num_str(rat_name{cr},2)];
        pathStat = fullfile(pathA,[Stat0 '_' nameID]);
        path_stat{su}=pathStat;
        if ~exist(pathStat,'dir'), mkdir(pathStat); end
        %Get basic info from the EPIP files
        if asl == 1
            fname0 = fullfile(path0,[scan '.dcm'],'slice001image0001echo001.dcm');
        else
            fname0 = fullfile(path0,[scan '.dcm'],'slice001image001echo001.dcm');
        end
        Y0 = dicomread(fname0);
        V0 = dicominfo(fname0);
        [nx ny] = size(Y0);
        try
            Nslice = V0.ImagesInAcquisition;
        catch exception
            Nslice = 12;
        end
        if use_physiology
            reg = mri_load_rat_physiology_respirationOnly(fullfile(mainPath,'Respiration'),['HC' nameID]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 1: Copy T1 image to convenient location and change name
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear matlabbatch
        fnameT1 = fullfile(path0, 'T1.nii');
        if ~exist(fnameT1,'file') || force_T1
            pathT1 = fullfile(path0,'tempT1.nii');
            if ~exist(pathT1,'dir'), mkdir(pathT1); end
            matlabbatch = mri_set_matlabbatch_old_rats_dicom_to_nifti(path0,pathT1,fsems_scan,1,Nslice);
            spm_jobman('run',matlabbatch);
            [files,dirs] = spm_select('FPList',pathT1,'.*');
            [dir0 fil0 ext0] = fileparts(files(1,:));
            movefile(files(1,:),fnameT1);
            rmdir(dir0)
        end
        % fnameAnat = fullfile(path0,[fsems_scan '.nii'],'volume0001.nii');
        fnameAnat = fullfile(path0,['T1' '.nii']);
        V1 = spm_vol(fnameAnat);
        T1 = spm_read_vols(V1);
        VT1 = V1;
        fnameT1 = fullfile(path0,'T1.nii');
        VT1.fname = fnameT1;
        if ~exist(VT1.fname,'file') || force_T1
            spm_write_vol(VT1,T1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 2: Load the DICOM EPIP information
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Rx = V0.PixelSpacing(1);
        %Ry = V0.PixelSpacing(2);
        %thk = V0.SliceThickness;
        switch V0.SequenceName
            case 'epip'
                TR = 2*V0.RepetitionTime/1000;
            case 'epi'
                TR = V0.RepetitionTime/1000;
        end
        V0.ImagePositionPatient;
        T = N*TR; %11 minutes approximately
        Y = zeros(nx,ny,Nslice,N);
        % Code to load epip data
        for i0 = 1:N
            for s0 = 1:Nslice
                fname = fullfile(path0,[scan '.dcm'],['slice' gen_num_str(s0,3) 'image' gen_num_str(i0,3) 'echo001.dcm']);
                tY = dicomread(fname);
                Y(:,:,s0,i0) = tY;
            end
        end    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 3: convert the DICOM data to NIFTI, to use in SPM8
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist(pathNii,'dir')
            %Only convert DICOM if pathNii does not exist. Otherwise, do
            %not run it -- delete the folder if you need to rerun
            mkdir(pathNii);
            clear matlabbatch
            matlabbatch = mri_set_matlabbatch_old_rats_dicom_to_nifti(path0,pathNii,scan,N,Nslice);
            spm_jobman('run',matlabbatch);
            [files,dirs] = spm_select('FPList',pathNii,'.*');
            for t0 = 1:size(files,1)
                [dir0 fil0 ext0] = fileparts(files(t0,:));
                movefile(files(t0,:),fullfile(dir0,['volume' gen_num_str(t0,3) '.nii']));
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 4: average BOLD image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         M = mean(Y,4);
%         %Plot average image on 3 x 4 subplot
%         figure;
%         for i=1:Nslice
%             subplot(3,4,i);
%             %Double inversion for plot and axis xy -- invert only on display
%             imagesc(squeeze(M(end:-1:1,end:-1:1,i)));
%             %imagesc(squeeze(M(10:82,10:82,i)));
%             %imagesc(squeeze(Y(10:82,10:82,i,1)));
%             axis off; axis xy;
%         end;
%         colormap(gray);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 5: construct stimulation protocol
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         lp = linspace(T/N,T,N);
%         C0 = [1:90   121:210 241:330 361:450 481:570 601:660];
%         C1 = [91:120 211:240 331:360 451:480 571:600];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 6: Use SPM8 to estimate the GLM -- see batch in the scripts folder
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %onsets = ons{cr}; %[90 210 330 450 570]; %duration: 30
        fname = fullfile(pathNii,'srvolume002.nii');
        if ~exist(fname,'file') || force_preprocess
            clear matlabbatch
            matlabbatch = mri_set_matlabbatch_old_rats_realign_smooth(pathNii,N,remove_first_scan);
            spm_jobman('run',matlabbatch);
        end
        
        if ~exist(fullfile(pathStat,'SPM.mat'),'file') || force_stats
            clear matlabbatch
            matlabbatch = mri_set_matlabbatch_old_rats_glm_estimate(pathNii,N,...
                pathStat,ons0,dur_eff0,TR,HPF,remove_first_scan,MVT,scaling_GLM);
            spm_jobman('run',matlabbatch);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 7: Superpose t-stat on anatomical and zoom a bit to remove the ear!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %T1
        V_T1 = spm_vol(fnameT1);
        T1 = spm_read_vols(V_T1);
        %Tstat BOLD
        Vb = spm_vol(fullfile(pathStat,'spmT_0001.img'));
        Yb = spm_read_vols(Vb);
        Yr = zeros(size(T1));
        %Load SPM.mat, for threshold
        [nxT1 nyT1 nzT1] = size(T1);
        fsems_to_epi_ratio = nxT1/nx;
        
        %resize:
        for i0=1:Nslice
            %Yr(:,:,Nslice+1-i0) = imresize(squeeze(Yb(end:-1:1,end:-1:1,i0)),fsems_to_epi_ratio);
            Yr(:,:,i0) = imresize(squeeze(Yb(:,:,i0)),fsems_to_epi_ratio,interp_option);
        end
        
        %Select a subregion
        ax = 1:256; %10:180; %vertical
        ay = 1:256; %30:230; %horizontal
        %ax = 1:256; ay = 1:256;
        T1s = T1(ax,ay,:);
        %T1s = T1s(end:-1:1,end:-1:1,:);
        Y2 = Yr(ax,ay,:);
        %Y2 = Yb;
        th = 4.5; %1.95;
        %Ov = 0.99*th*(T1s/max(T1s(:))-0.5);
        mn = min(T1s(:));
        mx = max(T1s(:));
        Ov = 0.9*th*((T1s-mn)/mx-0.5)*2;
        thf = 1.2*th;
        Ov(Y2<-thf) = Y2(Y2<-thf);
        Ov(Y2>thf) = Y2(Y2>thf);
        
        djet = jet(2*64);
        cool = djet(1:64,:);
        cmap = [cool; gray(64); hot(64)];
        h = figure;
        %clims = [-max(Y2(:)) max(Y2(:))];
        clims = [min(Y2(:)) -min(Y2(:))];
        for i=1:Nslice
            subplot(3,4,i);
            %imagesc(squeeze(Yr(:,:,i)));
            imagesc(squeeze(Ov(:,:,i))',clims);
            axis off; axis xy;
            if i==Nslice
                colorbar
            end
        end;
        colormap(cmap);
        pathF = fullfile(pathA,Stat1);
        if ~exist(pathF,'dir'),mkdir(pathF); end
        fname = fullfile(pathF,nameID);
        print(h, '-dpng', [fname '.png'], '-r300');
        close(h)
        
        output_each_slice_separately = 0;
        if output_each_slice_separately
            for i=1:Nslice
                h=figure;
                imagesc(squeeze(Ov(:,:,i))',clims);
                title(['Subject #' num2str(su) ' / slice #' num2str(i)])
                axis off; axis xy;
                colormap(cmap);
                hc1 = colorbar('EastOutside');
                hc2 = colorbar('WestOutside');
                sbar = linspace(clims(1), clims(2), 192);
%                 hc2 = nirs_set_colorbar(hc2,sbar(1),sbar(64),5,12);
%                 hc1 = nirs_set_colorbar(hc1,sbar(129),sbar(192),5,12);
                pathF = fullfile(pathA,Stat1);
                if ~exist(pathF,'dir'),mkdir(pathF); end
                fname = fullfile(pathF,nameID);
                print(h, '-dpng', [fname gen_num_str(i,2) '.png'], '-r300');
%                 close(h)
            end
        end
        
        look_at_time_courses = 0;
        if look_at_time_courses
            %Code to load epip data
            for i0 = first_scan:N
                fname = fullfile(path0,[scan '.nii'],['srvolume' gen_num_str(i0,3) '.nii']);
                tV = spm_vol(fname);
                tY = spm_read_vols(tV);
                Z(:,:,:,i0) = tY;
            end
            T = N*TR;
            lp = linspace(T/N+(first_scan-1)*TR,T,N-first_scan+1);
            Z = Z(:,:,:,first_scan:end);
            figure; plot(lp,squeeze(Z(35,48,10,:)));
            figure; plot(lp,squeeze(mean(mean(Z(35-1:35+1,48-1:48+1,10,:),1),2)));
            title(['Subject #' num2str(su)]);
            figure; plot(lp,squeeze(mean(mean(Z(35-2:35+2,48-2:48+2,10,:),1),2)));
            title(['Subject #' num2str(su)]);
            figure; plot(lp,squeeze(mean(mean(Z(35-3:35+3,48-3:48+3,10,:),1),2)));
            title(['Subject #' num2str(su)]);
        end
    end
   
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    try
        disp(exception.stack(2))
        disp(exception.stack(3))
    end
end